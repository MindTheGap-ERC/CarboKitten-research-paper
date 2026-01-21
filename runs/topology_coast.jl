# ~/~ begin <<md/paper.md#runs/topology_coast.jl>>[init]
module TopologyCoast

using CarboKitten
using CarboKitten.Models: ALCAP as M

function main()
    CarboKitten.init()

    facies = [
        M.Facies(
            maximum_growth_rate=500u"m/Myr",
            extinction_coefficient=0.8u"m^-1",
            saturation_intensity=60u"W/m^2",
            diffusion_coefficient=10.0u"m/yr"),
        M.Facies(
            maximum_growth_rate=400u"m/Myr",
            extinction_coefficient=0.1u"m^-1",
            saturation_intensity=60u"W/m^2",
            diffusion_coefficient=10.0u"m/yr"),
        M.Facies(
            maximum_growth_rate=100u"m/Myr",
            extinction_coefficient=0.005u"m^-1",
            saturation_intensity=60u"W/m^2",
            diffusion_coefficient=10.0u"m/yr")
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

    coast_input = M.Input(
        time = TimeProperties(
            Δt=0.0002u"Myr",
            steps=5000),
        box = Box{Coast}(
            grid_size=(250, 50),
            phys_scale=60.0u"m"),
        facies = facies,
        initial_topography = (x, y) -> let x_prime = x - 3.0u"km"
            x_prime > 0.0u"km" ? - x_prime / 300.0 : - x_prime / 30.0
        end,
        output = Dict(
            :topography => OutputSpec(write_interval = 1000),
            :profile => OutputSpec(slice = (:, 25)));
        kwargs...)

    run_model(Model{M}, coast_input, "data/topology_coast.h5")
end

end

TopologyCoast.main()
# ~/~ end
