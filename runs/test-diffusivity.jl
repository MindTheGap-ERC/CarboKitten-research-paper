# ~/~ begin <<md/paper.md#runs/test-diffusivity.jl>>[init]
#| file: runs/test-diffusivity.jl
using CarboKitten
using CarboKitten.Components:
    TimeIntegration, Boxes, FaciesBase, SedimentBuffer, WaterDepth, 
    Tag, ActiveLayer, H5Writer
using CarboKitten.Components.Common
using ModuleMixins

@compose module CustomProduction
@mixin Tag, ActiveLayer, H5Writer

@kwdef struct Input <: AbstractInput
    production    # a function of (x, y, wd)
end

function initial_state(input::AbstractInput)
    sediment_height = zeros(Height, input.box.grid_size...)
    sediment_buffer = zeros(Float64, input.sediment_buffer_size, n_facies(input), input.box.grid_size...)
    active_layer = zeros(Amount, n_facies(input), input.box.grid_size...)

    state = State(
        step=0, sediment_height=sediment_height,
        sediment_buffer=sediment_buffer,
        active_layer = active_layer)

    return state
end

function step!(input::Input)
    disintegrate! = ActiveLayer.disintegrator(input)
    transport! = ActiveLayer.transporter(input)
    local_water_depth = water_depth(input)
    x, y = box_axes(input.box)
    na = [CartesianIndex()]
    produce(_, wd) = input.production.(x[:,na], y[na,:], wd)[na,:,:]
    pf = precipitation_factor(input)

    function (state::State)
        wd = local_water_depth(state)
        p = produce(state, wd)
        d = disintegrate!(state)

        state.active_layer .+= p
        state.active_layer .+= d
        transport!(state)

        deposit = pf .* state.active_layer
        push_sediment!(state.sediment_buffer, deposit ./ input.depositional_resolution .|> NoUnits)
        state.active_layer .-= deposit
        state.sediment_height .+= sum(deposit; dims=1)[1,:,:]
        state.step += 1

        return Frame(
            production = p,
            disintegration = d,
            deposition = deposit)
    end
end

end

module ParameterScan

function cartesian_product(pars::Dict{Key,Vector}) where {Key}
    if isempty(pars)
        return [ Dict{Key, Any}() ]
    end

    pars = copy(pars)
    result = []

    k, vs = first(pairs(pars))

    for item in cartesian_product(delete!(pars, k))
        for v in vs
            push!(result, merge(item, Dict(k => v)))
        end
    end

    return result
end

kwsplat(f) = d -> f(;d...)

end

module TestDiffusivity

using CarboKitten
using ..CustomProduction: CustomProduction as M

const Time = typeof(1.0u"Myr")

function run_model(;dt, diffusivity, disintegration_rate)
end

function main()
    facies = [
        M.Facies(
            # maximum_growth_rate=500u"m/Myr",
            # extinction_coefficient=0.8u"m^-1",
            # saturation_intensity=60u"W/m^2",
            diffusion_coefficient=10.0u"m/yr")
    ]

    box = Box{Periodic{2}}(
        grid_size=(500, 1), phys_scale=30.0u"m")

    time = TimeProperties(
        Δt=0.0002u"Myr",
        steps=5000)

    width = 0.5u"km"
    centre = box.grid_size[1] * box.phys_scale / 2.0
    production(x, y, w) = abs(x - centre) < width ?
        100.0u"m/Myr" * time.Δt :
        0.0u"m"
        
    input = M.Input(
        box=box,
        time=time,
        output = Dict(
            :all => OutputSpec(write_interval=1)),
        initial_topography=(_, _) -> -100.0u"m",
        sea_level=t -> 0.0u"m",
        subsidence_rate=0.0u"m/Myr",
        disintegration_rate=50.0u"m/Myr",
        # insolation=400.0u"W/m^2",
        sediment_buffer_size=50,
        depositional_resolution=0.5u"m",
        transport_solver=Val{:forward_euler},
        facies=facies,

        production=production)

    result = run_model(Model{M}, input, MemoryOutput(input))
end

end

TestDiffusivity.main()
# ~/~ end
