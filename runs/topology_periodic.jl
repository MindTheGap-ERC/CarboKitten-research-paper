# ~/~ begin <<md/paper.md#runs/topology_periodic.jl>>[init]
include("Noise.jl")

module TopologyPeriodic

using CarboKitten
using CarboKitten.Production
using CarboKitten.Models: ALCAP as M
using ..Noise: make_noise

function main()
    CarboKitten.init()

    facies = [
        M.Facies(
            production=Production.EXAMPLE[:euphotic],
            transport_coefficient=10.0u"m/yr"),
        M.Facies(
            production=Production.EXAMPLE[:oligophotic],
            transport_coefficient=10.0u"m/yr"),
        M.Facies(
            production=Production.EXAMPLE[:aphotic],
            transport_coefficient=10.0u"m/yr")
    ]

    sea_level(t) =
        10.0u"m" * sin(2π * t / 123456.0u"yr") +
         5.0u"m" * sin(2π * t /  23456.0u"yr")

    kwargs = (
        sea_level = sea_level,
        subsidence_rate=50.0u"m/Myr",
        disintegration_rate=50.0u"m/Myr",
        insolation=400.0u"W/m^2",
        sediment_buffer_size=50,
        depositional_resolution=0.5u"m",
        transport_solver=Val{:forward_euler},
    )

    box = Box{Periodic{2}}(grid_size=(256, 256), phys_scale=60.0u"m")
    initial_topography = make_noise(box, -1.5, 5.0u"m", 1.0u"km") .* 1.0u"m" .- 30.0u"m"

    coast_input = M.Input(
        time = TimeProperties(
            Δt=0.0002u"Myr",
            steps=5000),
        box = box,
        facies = facies,
        initial_topography = initial_topography,
        output = Dict(
            :topography => OutputSpec(write_interval = 500),
            :profile_x => OutputSpec(slice = (:, 125)),
            :profile_y => OutputSpec(slice = (125, :)));
        kwargs...)

    run_model(Model{M}, coast_input, "data/topology_periodic.h5")
end

end

TopologyPeriodic.main()
# ~/~ end
