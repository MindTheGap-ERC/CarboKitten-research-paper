# ~/~ begin <<md/paper.md#runs/validation_case.jl>>[init]
#| file: runs/validation_case.jl
#| creates: md/fig/validation.png

module ValidationPrerun

using Unitful
using CarboKitten
using DelimitedFiles
using DataFrames
using Interpolations
using CairoMakie
using CarboKitten.Visualization: sediment_profile, summary_plot
using CarboKitten.Export: read_slice, read_volume, write_csv
using Tables
using CarboKitten.Boxes: Periodic
const TAG = "alcap-validation"
const FILEPATH = "data/Morley_2021.txt"
const DATAFILE = "data/validation_prerun_topography.csv"
const OUTPUT_FILE = "data/validationprerun.h5"


function dome_topography(x, y)
    radius = sqrt(20.0 / π) * u"km"
    center_x, center_y = 40u"km", 25u"km"
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
        maximum_growth_rate=500u"m/Myr",
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
        maximum_growth_rate=100u"m/Myr",
        extinction_coefficient=0.1u"m^-1",
        saturation_intensity=60u"W/m^2",
        diffusion_coefficient=12.5u"m/yr")
]

const INPUT = ALCAP.Input(
    tag=TAG,
    box=CarboKitten.Box{Periodic{2}}(grid_size=(140, 100), phys_scale=50u"m"),
    time=TimeProperties(
        Δt=0.0001u"Myr",
        steps=10000
    ),
    output=Dict(
        :topography => OutputSpec(write_interval=1000),
        :profile => OutputSpec(slice=(:, 50), write_interval=500)
    ),
    ca_interval=1,
    initial_topography = dome_topography,
    sea_level= t -> 20.0u"m",
    subsidence_rate=20.0u"m/Myr",
    disintegration_rate=50.0u"m/Myr",
    insolation=400.0u"W/m^2",
    sediment_buffer_size=50,
    depositional_resolution=0.5u"m",
    facies=FACIES)

function main()
    run_model(Model{ALCAP}, INPUT, "$OUTPUT_FILE")
end

function save_final_topography(prerun_filename)
    header, data = read_volume(prerun_filename, :topography)

    t = header.axes.t
    h0 = header.initial_topography
    subsidence = header.subsidence_rate * (t[end] - t[1])
    delta_h = data.sediment_thickness[:, :, end]
    h = h0 .+ delta_h .- subsidence

    write_csv(DATAFILE, h |> in_units_of(u"m") |> Tables.table)
end

function preplot()
    header, data = read_slice("$OUTPUT_FILE", :profile)
	fig = sediment_profile(header, data, show_unconformities = false)
    save("md/fig/validation_prerun.png", fig)
end
end

result = ValidationPrerun.main()
ValidationPrerun.save_final_topography(ValidationPrerun.OUTPUT_FILE)
ValidationPrerun.preplot()
# ~/~ end
