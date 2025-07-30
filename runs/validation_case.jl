# ~/~ begin <<md/paper.md#runs/validation_case.jl>>[init]
#| file: runs/validation_case.jl
#| creates: md/fig/validation.png

module Validation

using Unitful
using CarboKitten
using DelimitedFiles
using DataFrames
using Interpolations
const PATH = "data"

const TAG = "alcap-validation"
const FILEPATH = "data/Morley_2021.txt"

function sea_level(filepath::String)
    sealevel_data, header = readdlm(filepath,header=true)
    sealevel_data_df = DataFrame(sealevel_data, vec(header))
    sealevel_data_df = filter(row -> 8.0 <= row.Time <= 15.5, sealevel_data_df) # cycles IV-V
    sort!(sealevel_data_df, [:Time], rev=true)
    Time = sealevel_data_df.Time .* 1.0u"Myr"
    Sealevel = sealevel_data_df.Sealevel .* 1.0u"m"
    sl_interpolated = LinearInterpolation(
        Time, Sealevel)
    return sl_interpolated
end


const FACIES = [
    ALCAP.Facies(
        viability_range = (4, 10),
        activation_range = (6, 10),
        maximum_growth_rate=250u"m/Myr",
        extinction_coefficient=0.8u"m^-1",
        saturation_intensity=60u"W/m^2",
        diffusion_coefficient=50.0u"m/yr"),
    ALCAP.Facies(
        viability_range = (4, 10),
        activation_range = (6, 10),
        maximum_growth_rate=200u"m/Myr",
        extinction_coefficient=0.1u"m^-1",
        saturation_intensity=60u"W/m^2",
        diffusion_coefficient=25.0u"m/yr"),
    ALCAP.Facies(
        viability_range = (4, 10),
        activation_range = (6, 10),
        maximum_growth_rate=50u"m/Myr",
        extinction_coefficient=0.005u"m^-1",
        saturation_intensity=60u"W/m^2",
        diffusion_coefficient=12.5u"m/yr")
]

const INPUT = ALCAP.Input(
    tag="$TAG",
    box=Box{Coast}(grid_size=(100, 50), phys_scale=150.0u"m"),
    time=TimeProperties(
        t0 = -15.5u"Myr",
        Δt=200u"yr",
        steps=37500),
    output=Dict(
        :profile => OutputSpec(slice=(:, 25), write_interval=10)),
    ca_interval=10,
    initial_topography = (x, y) -> (sqrt((x - 50)^2 + (y - 25)^2) < 20 ? 5.0 : 0.0), #this is meant to be a flat-topped dome
    sea_level=sea_level(FILEPATH),
    subsidence_rate=50.0u"m/Myr",
    disintegration_rate=50.0u"m/Myr",
    insolation=400.0u"W/m^2",
    sediment_buffer_size=50,
    depositional_resolution=0.5u"m",
    facies=FACIES)

function main()
    run_model(Model{ALCAP}, INPUT, MemoryOutput(INPUT))
end

function plot(result::MemoryOutput)
	fig = sediment_profile(result.header, result.data_slices[:profile])
    save("md/fig/validation_Miocene.png", fig)
end

end

result = Validation.main()
Validation.plot(result)
# ~/~ end
