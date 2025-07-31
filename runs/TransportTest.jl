# ~/~ begin <<md/paper.md#runs/TransportTest.jl>>[init]
#| file: runs/TransportTest.jl
module TransportTest

include("CustomProductionModel.jl")

using CarboKitten
using CairoMakie
using CarboKitten: Box
using CarboKitten.OutputData: set_attribute
using .CustomProduction: CustomProduction as M

const Time = typeof(1.0u"Myr")

function run_with(;dt, diffusivity, disintegration_rate, cementation_time, patch_width = 2.0u"km")
    facies = [
        M.Facies(
            diffusion_coefficient=diffusivity)  # 10u"m/yr"
    ]

    box = Box{Periodic{2}}(
        grid_size=(500, 1), phys_scale=30.0u"m")

    t_end = 1.0u"Myr"
    time = TimeProperties(
        Δt = dt,
        steps = (t_end / dt) |> round |> Int)

    @info "Running at Δt = $(time.Δt) and steps = $(time.steps)"
    @info "Production in a single step: $(100.0u"m/Myr" * time.Δt)"


    centre = box.grid_size[1] * box.phys_scale / 2.0
    production(x, y, w) = abs(x - centre) < patch_width ?
        100.0u"m/Myr" * time.Δt :
        0.0u"m"

    write_interval = div(time.steps, 100)

    input = M.Input(
        box=box,
        time=time,
        output = Dict(
            :all => OutputSpec(write_interval=write_interval)),
        initial_topography=(_, _) -> -100.0u"m",
        sea_level=t -> 0.0u"m",
        subsidence_rate=0.0u"m/Myr",
        disintegration_rate=disintegration_rate,
        sediment_buffer_size=50,
        depositional_resolution=0.5u"m",
        cementation_time=cementation_time,
        transport_solver=Val{:forward_euler},
        facies=facies,

        production=production)

    result = run_model(Model{M}, input, MemoryOutput(input))
    set_attribute(result, :diffusivity, diffusivity)
    set_attribute(result, :disintegration_rate, disintegration_rate)
    return result
end

end
# ~/~ end
