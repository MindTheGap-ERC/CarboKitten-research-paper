# ~/~ begin <<md/paper.md#runs/atoll.jl>>[init]
#| file: runs/atoll.jl
#| classes: ["task"]
#| creates: data/atoll.h5
#| collect: atoll
using CarboKitten

module Atoll

using CarboKitten
using GeometryBasics

# ~/~ begin <<md/paper.md#velocity-profile>>[init]
#| id: velocity-profile
v_prof(v_max, max_depth, w) = 
    let k = sqrt(0.5) / max_depth,
        A = 3.331 * v_max,
        α = tanh(k * w),
        β = exp(-k * w)
        (A * α * β, -A * k * β * (1 - α - α^2))
    end
# ~/~ end

wave_velocity(v_max) = w -> let (v, s) = v_prof(v_max, 10.0u"m", w)
        (Vec2(v, 0.0u"m/Myr"), Vec2(s, 0.0u"1/Myr"))
    end

initial_topography(x, y) = 
    - sqrt((x - 7.5u"km")^2 + (y - 7.5u"km")^2) / 100.0

const INTERTIDAL_ZONE = 10.0u"m"

const FACIES = [
    ALCAP.Facies(
        viability_range=(4, 10),
        activation_range=(6, 10),
        maximum_growth_rate=500u"m/Myr",
        extinction_coefficient=0.8u"m^-1",
        saturation_intensity=60u"W/m^2",
        diffusion_coefficient=10.0u"m/yr",
        wave_velocity=wave_velocity(-0.5u"m/yr")),
    ALCAP.Facies(
        viability_range=(4, 10),
        activation_range=(6, 10),
        maximum_growth_rate=400u"m/Myr",
        extinction_coefficient=0.1u"m^-1",
        saturation_intensity=60u"W/m^2",
        diffusion_coefficient=10.0u"m/yr",
        wave_velocity=wave_velocity(-2.0u"m/yr")),
    ALCAP.Facies(
        viability_range=(4, 10),
        activation_range=(6, 10),
        maximum_growth_rate=100u"m/Myr",
        extinction_coefficient=0.005u"m^-1",
        saturation_intensity=60u"W/m^2",
        diffusion_coefficient=10.0u"m/yr",
        wave_velocity=wave_velocity(-2.0u"m/yr"))
]

const BOX = Box{Periodic{2}}(
    grid_size=(300, 300), phys_scale=50.0u"m")

const INPUT = ALCAP.Input(
    tag="atoll",
    box=BOX,
    time=TimeProperties(
        Δt=0.0002u"Myr",
        steps=4000),
    output = Dict(
        :topography => OutputSpec(write_interval=400),
        :profile => OutputSpec(slice=(:, 150)),
        :offcenter => OutputSpec(slice=(:, 225))),
    ca_interval=1,
    initial_topography=initial_topography,
    sea_level=t -> 5.0u"m" * sin(2π * t / 123456.0u"yr"),
    subsidence_rate=50.0u"m/Myr",
    disintegration_rate=50.0u"m/Myr",
    insolation=400.0u"W/m^2",
    sediment_buffer_size=50,
    depositional_resolution=0.5u"m",
    transport_solver=Val{:forward_euler},
    intertidal_zone=INTERTIDAL_ZONE,
    facies=FACIES)

end

CarboKitten.init()
CarboKitten.run_model(Model{ALCAP}, Atoll.INPUT, "data/atoll.h5")
# ~/~ end