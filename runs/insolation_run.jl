# ~/~ begin <<md/paper.md#runs/insolation_run.jl>>[init]
#| file: runs/insolation_run.jl

module Insolation

using CarboKitten
using DelimitedFiles: readdlm
using Unitful
using Interpolations
using CairoMakie
using CarboKitten.Visualization: sediment_profile
using Statistics

function import_insolation(file::String)
    dir = "data"
    filename = joinpath(dir, file)
    insolation = readdlm(filename, '\t', header=false, skipstart=1)
    vec(insolation) .|> Float64
end

const TIME_PROPERTIES = TimeProperties(
    t0 = 0u"Myr",
    Δt = 200.0u"yr",
    steps = length(import_insolation("insolation.csv"))-1
)

function get_insolation(times::Vector, insolation::Vector)
	interpolator = linear_interpolation(times, insolation)
    return t -> interpolator(ustrip(u"yr", t)) * u"W/m^2"
end

const TAG = "insolation-future"

const FACIES = [
    ALCAP.Facies(
        viability_range=(4, 10),
        activation_range=(6, 10),
        maximum_growth_rate=200u"m/Myr",
        extinction_coefficient=0.8u"m^-1",
        saturation_intensity=60u"W/m^2",
        diffusion_coefficient=50.0u"m/yr"),
    ALCAP.Facies(
        viability_range=(4, 10),
        activation_range=(6, 10),
        maximum_growth_rate=500u"m/Myr",
        extinction_coefficient=0.1u"m^-1",
        saturation_intensity=60u"W/m^2",
        diffusion_coefficient=25.0u"m/yr"),
    ALCAP.Facies(
        viability_range=(4, 10),
        activation_range=(6, 10),
        maximum_growth_rate=100u"m/Myr",
        extinction_coefficient=0.005u"m^-1",
        saturation_intensity=60u"W/m^2",
        diffusion_coefficient=35.0u"m/yr")
]

const time_vector = collect(time_axis(TIME_PROPERTIES)) / u"yr" .|> NoUnits
const insolation_vector = import_insolation("insolation.csv")

function get_sea_level(times::Vector, insolation::Vector)
    insolation_anomaly = (insolation .- mean(insolation)) ./ mean(insolation)
    sea_level_anomaly = -(100 .* (insolation_anomaly)) .^ 2
    sea_level_values = -100.0 .+ sea_level_anomaly
    interpolator = linear_interpolation(times, sea_level_values)
    return t -> interpolator(ustrip(u"yr", t)) * u"m"
end

const INPUT = ALCAP.Input(
    tag="$TAG",
    box=CarboKitten.Box{Coast}(grid_size=(100, 50), phys_scale=150.0u"m"),
    time=TIME_PROPERTIES,
    ca_interval=1,
    initial_topography=(x, y) -> -x / 200.0 - 100.0u"m",
    sea_level = get_sea_level(time_vector, insolation_vector),
        output=Dict(
        :profile => OutputSpec(slice=(:, 25), write_interval=1)),
    subsidence_rate=50.0u"m/Myr",
    disintegration_rate=50.0u"m/Myr",
    insolation= get_insolation(time_vector, insolation_vector),
    sediment_buffer_size=50,
    depositional_resolution=0.5u"m",
    facies=FACIES)

    function main()
        run_model(Model{ALCAP}, INPUT, MemoryOutput(INPUT))
    end

    function plot(result::MemoryOutput)
	    fig = sediment_profile(result.header, result.data_slices[:profile])
        save("md/fig/variable-insolation.png", fig)
end

end

result = Insolation.main()
Insolation.plot(result)
# ~/~ end