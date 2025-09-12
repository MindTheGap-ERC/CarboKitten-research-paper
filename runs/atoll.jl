# ~/~ begin <<md/paper.md#runs/atoll.jl>>[init]
#| file: runs/atoll.jl
#| classes: ["task"]
#| creates: data/atoll.h5
#| collect: atoll

module Atoll

using CarboKitten
using GeometryBasics
using .Threads: @threads

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

v_none(_) = w -> (Vec2(0.0, 0.0) * u"m/yr", Vec2(0.0, 0.0) * u"1/yr")

v_prof(v_max) = w -> let (v, s) = v_prof(v_max, 10.0u"m", w)
        (Vec2(v, 0.0u"m/Myr"), Vec2(s, 0.0u"1/Myr"))
    end

v_flat(v_max) = _ -> (Vec2(v_max, 0.0u"m/yr"), Vec2(0.0u"1/yr", 0.0u"1/yr"))

initial_topography(x, y) = 
    - sqrt((x - 7.5u"km")^2 + (y - 7.5u"km")^2) / 100.0

facies(v) = [
    ALCAP.Facies(
        viability_range=(4, 10),
        activation_range=(6, 10),
        maximum_growth_rate=500u"m/Myr",
        extinction_coefficient=0.8u"m^-1",
        saturation_intensity=60u"W/m^2",
        diffusion_coefficient=20.0u"m/yr",
        wave_velocity=v(-2.0u"m/yr")),
    ALCAP.Facies(
        viability_range=(4, 10),
        activation_range=(6, 10),
        maximum_growth_rate=400u"m/Myr",
        extinction_coefficient=0.1u"m^-1",
        saturation_intensity=60u"W/m^2",
        diffusion_coefficient=10.0u"m/yr",
        wave_velocity=v(-0.5u"m/yr")),
    ALCAP.Facies(
        viability_range=(4, 10),
        activation_range=(6, 10),
        maximum_growth_rate=100u"m/Myr",
        extinction_coefficient=0.005u"m^-1",
        saturation_intensity=60u"W/m^2",
        diffusion_coefficient=50.0u"m/yr",
        wave_velocity=v(-2.0u"m/yr"))
]

box(res) = Box{Periodic{2}}(
    grid_size=(res, res),
    phys_scale=15.0u"km" / res)

time(steps) = TimeProperties(
    Δt=1.0u"Myr" / steps,
    steps=steps)

output(res, steps) = Dict(
    :topography => OutputSpec(write_interval = max(1, div(steps, 50))),
    :profile    => OutputSpec(slice = (:, div(res, 2)+1)))

ca_interval(steps) = max(div(steps, 5000), 1)

sea_level(t) =
    10.0u"m" * sin(2π * t / 123456.0u"yr") +
     5.0u"m" * sin(2π * t /  23456.0u"yr")

input(name, res, steps, v) = ALCAP.Input(
    tag="atoll_$(res)_$(name)",
    box=box(res),
    time=time(steps),
    output=output(res, steps),
    ca_interval=ca_interval(steps),
    initial_topography=initial_topography,
    sea_level=sea_level,
    subsidence_rate=50.0u"m/Myr",
    disintegration_rate=50.0u"m/Myr",
    cementation_time=100.0u"yr",
    insolation=400.0u"W/m^2",
    sediment_buffer_size=50,
    depositional_resolution=0.5u"m",
    transport_solver=Val{:forward_euler},
    ca_random_seed=2,
    facies=facies(v))

function main()
    CarboKitten.init()
    vs = [
        :none => v_none,
        :flat => v_flat,
        :prof => v_prof
    ]

    @threads for (n, v) in vs
        inp = input(n, 150, 5000, v)
        run_model(Model{ALCAP}, inp, "data/$(inp.tag).h5")
    end
end

end

Atoll.main()
# ~/~ end
