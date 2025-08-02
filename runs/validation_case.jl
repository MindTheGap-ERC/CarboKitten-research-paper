# ~/~ begin <<md/paper.md#runs/validation_case.jl>>[init]
#| file: runs/validation_case.jl
#| creates: md/fig/validation.png

module Validation

using Unitful
using CarboKitten
using DelimitedFiles
using DataFrames
using Interpolations
using CairoMakie
using CarboKitten.Visualization: sediment_profile
using CarboKitten.Export: read_slice

const TAG = "alcap-validation"
const FILEPATH = "data/Morley_2021.txt"
const OUTPUT_FILE = "data/validation.h5"

function sea_level(filepath::String)
    sealevel_data, header = readdlm(filepath,header=true)
    sealevel_data_df = DataFrame(sealevel_data, vec(header))
    sealevel_data_df = filter(row -> 8.0 <= row.Time <= 15.5, sealevel_data_df) # cycles IV-V
    sort!(sealevel_data_df, [:Time], rev=true)
    Time = sealevel_data_df.Time .* -1.0u"Myr"
    Sealevel = sealevel_data_df.Sealevel .* 1.0u"m"
    sl_interpolated = LinearInterpolation(
        Time, Sealevel)
    return sl_interpolated
end

function dome_topography(x, y)
    radius = sqrt(60.0 / π) * u"km"
    center_x, center_y = 25u"km", 25u"km"
    dist = sqrt((x - center_x)^2 + (y - center_y)^2)
    if dist <= radius
        20.0u"m"
    else
        slope = (dist - radius) / (1.0u"km")
        max(0.0u"m" - 100.0u"m", 20.0u"m" - 10.0u"m" * slope)
    end
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
    box=CarboKitten.Box{Coast}(grid_size=(100, 100), phys_scale=0.5u"km"),
    time=TimeProperties(
        t0 = -15.48u"Myr",
        Δt=200u"yr",
        steps=36600),
    output=Dict(
        :topography => OutputSpec(write_interval = 200),
        :profile => OutputSpec(slice=(:, 25), write_interval=50)),
    ca_interval=10,
    initial_topography = dome_topography,
    sea_level=sea_level(FILEPATH),
    subsidence_rate=25.0u"m/Myr",
    disintegration_rate=50.0u"m/Myr",
    insolation=400.0u"W/m^2",
    sediment_buffer_size=50,
    depositional_resolution=0.5u"m",
    facies=FACIES)

function main()
    run_model(Model{ALCAP}, INPUT, "$OUTPUT_FILE")
end

function plot()
    header, data = read_slice("$OUTPUT_FILE", :profile)
	fig = sediment_profile(header, data, show_unconformities = false)
    save("md/fig/validation_Miocene.png", fig)
end

end

result = Validation.main()

# ~/~ end
