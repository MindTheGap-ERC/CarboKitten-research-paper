# ~/~ begin <<md/paper.md#runs/benchmarks.jl>>[init]
#| file: runs/benchmarks.jl
module Benchmarks

using BenchmarkTools
using CarboKitten
using GeometryBasics
using DataFrames
using CSV

# A constant homogeneous wave velocity
v_const(v_max) = _ -> (Vec2(v_max, 0.0u"m/yr"), Vec2(0.0u"1/yr", 0.0u"1/yr"))

initial_topography(x, y) = 
    - sqrt((x - 7.5u"km")^2 + (y - 7.5u"km")^2) / 100.0

const FACIES = [
    ALCAP.Facies(
        viability_range=(4, 10),
        activation_range=(6, 10),
        maximum_growth_rate=500u"m/Myr",
        extinction_coefficient=0.8u"m^-1",
        saturation_intensity=60u"W/m^2",
        diffusion_coefficient=50.0u"m/yr",
        wave_velocity=v_const(-2.0u"m/yr")),
    ALCAP.Facies(
        viability_range=(4, 10),
        activation_range=(6, 10),
        maximum_growth_rate=400u"m/Myr",
        extinction_coefficient=0.1u"m^-1",
        saturation_intensity=60u"W/m^2",
        diffusion_coefficient=10.0u"m/yr",
        wave_velocity=v_const(-0.5u"m/yr")),
    ALCAP.Facies(
        viability_range=(4, 10),
        activation_range=(6, 10),
        maximum_growth_rate=100u"m/Myr",
        extinction_coefficient=0.005u"m^-1",
        saturation_intensity=60u"W/m^2",
        diffusion_coefficient=10.0u"m/yr",
        wave_velocity=v_const(-2.0u"m/yr"))
]

box(res) = Box{Periodic{2}}(
    grid_size=(res, res),
    phys_scale=15.0u"km" / res)

time(steps) = TimeProperties(
    Δt=1.0u"Myr" / steps,
    steps=steps)

output(res, steps) = Dict(
    :topography => OutputSpec(write_interval = max(1, div(steps, 50))),
    :profile    => OutputSpec(slice = (:, div(res, 2))))

ca_interval(steps) = max(div(steps, 5000), 1)

sea_level(t) =
    10.0u"m" * sin(2π * t / 123456.0u"yr") +
     5.0u"m" * sin(2π * t /  23456.0u"yr")

input(res, steps) = ALCAP.Input(
    tag="atoll_$(res)_$(steps)",
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
    facies=FACIES)


function cartesian_product(pars::Dict{Key,Vector{Elem}}) where {Key, Elem}
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

const BM = @NamedTuple{value::String, time::Float64, bytes::Int64, alloc::Int64, gctime::Float64}

function run_benchmark(; res, steps)
    output_file = "data/bench_$(res)_$(steps).h5"
    try
        bm = @btimed run_model(Model{ALCAP}, $(input(res, steps)), $output_file)
        return (res=res, steps=steps, bm...)
    catch e
        return (res=res, steps=steps, value="error", time=NaN, bytes=0, alloc=0, gctime=NaN)
    end
end

function main()
    CarboKitten.init()
    run_model(Model{ALCAP}, input(50, 1000), "data/bench_init.h5")

    pars = Dict(
        :res => [75, 150, 300],
        :steps => [2500, 5000, 10000] )

    results = DataFrame(res=Int[], steps=Int[], value=String[], time=Float64[], bytes=Int64[], alloc=Int64[], gctime=Float64[])

    for p in cartesian_product(pars)
        push!(results, run_benchmark(; p...))
    end

    CSV.write("data/benchmark.csv", results)
end

end

Benchmarks.main()
# ~/~ end
