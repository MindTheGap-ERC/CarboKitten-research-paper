module Validation

using Unitful
using CarboKitten
using DelimitedFiles
using DataFrames
using Interpolations
using CairoMakie
using Tables
using CSV
using CarboKitten.Visualization: sediment_profile
using CarboKitten.Export: read_slice

const TAG = "alcap-validation"
const FILEPATH = "data/Morley_2021.txt"
const OUTPUT_FILE = "data/validation.h5"

include("validation_prerun.jl")

function load_init_topo()
    (CSV.File(ValidationPrerun.DATAFILE) |> Tables.matrix) * u"m"
end

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


const INPUT = ALCAP.Input(
    tag="$TAG",
    box=ValidationPrerun.INPUT.box,
    time=TimeProperties(
        t0 = -15.48u"Myr",
        Δt=100u"yr",
        steps=36600*2),
    output=Dict(
        :topography => OutputSpec(write_interval = 1000),
        :profile => OutputSpec(slice=(:, 50), write_interval=50)),
    ca_interval=10,
    initial_topography = ValidationPrerun.dome_topography, #load_init_topo(),
    sea_level=sea_level(FILEPATH),
    subsidence_rate=30.0u"m/Myr",
    disintegration_rate=50.0u"m/Myr",
    insolation=400.0u"W/m^2",
    sediment_buffer_size=50,
    depositional_resolution=0.5u"m",
    facies=ValidationPrerun.INPUT.facies)

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
Validation.plot()