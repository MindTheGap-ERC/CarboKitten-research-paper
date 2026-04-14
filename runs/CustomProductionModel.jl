# ~/~ begin <<md/paper.md#runs/CustomProductionModel.jl>>[init]
using CarboKitten
using CarboKitten.Components.Common
using CarboKitten.Components:
    TimeIntegration, Boxes, FaciesBase, SedimentBuffer, WaterDepth,
    Tag, ActiveLayer, Output, Diagnostics
using CarboKitten.Output: Frame
using ModuleMixins: @compose, @for_each

@compose module CustomProduction
@mixin Tag, ActiveLayer, Output, Diagnostics

using CarboKitten.Output: Frame

@kwdef struct Input <: AbstractInput
    production    # a function of (x, y, wd)
end

function write_header(input::AbstractInput, output::AbstractOutput)
    @for_each(P -> P.write_header(input, output), PARENTS)
end

function initial_frame(input::AbstractInput)
    nf = n_facies(input)
    return Frame(
        production=zeros(Sediment, nf, input.box.grid_size...),
        disintegration=zeros(Sediment, nf, input.box.grid_size...),
        deposition=zeros(Sediment, nf, input.box.grid_size...))
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
    pf = lithification_factor(input)

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
# ~/~ end
