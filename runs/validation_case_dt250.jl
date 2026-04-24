module Validation

using Unitful
using CarboKitten
using DelimitedFiles
using DataFrames
using Interpolations
using CairoMakie
using Tables
using CSV
using CarboKitten.Visualization: sediment_profile!, summary_plot
using CarboKitten.Export: read_slice

const TAG = "alcap-validation"
const FILEPATH = "data/Morley_2021.txt"
const OUTPUT_FILE = "data/validation_dt250.h5"

include("validation_prerun.jl")
inch = 96
pt = 4/3
cm = inch / 2.54

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


input(feedback) = ALCAP.Input(
    tag="$TAG",
    box=ValidationPrerun.input(feedback).box,
    time=TimeProperties(
        t0 = -15.48u"Myr",
        Δt=250u"yr",
        steps=16000),
    output=Dict(
        :topography => OutputSpec(write_interval = 1000),
        :profile => OutputSpec(slice=(:, 50), write_interval=1)),
    ca_interval=10,
    ca_random_seed = 1,
    initial_topography = load_init_topo(), 
    sea_level=sea_level(FILEPATH),
    subsidence_rate=150.0u"m/Myr",
    transport_solver = Val{:forward_euler},
    disintegration_rate=50.0u"m/Myr",
    insolation=400.0u"W/m^2",
    sediment_buffer_size=50,
    depositional_resolution=0.5u"m",
    lithification_time = 100.0u"yr",
    disintegration_transfer = f -> stack((0.0.*f[1,:,:], 0.0.*f[2,:,:], 0.0.*f[3,:,:],
                                      f[2,:,:].+f[4,:,:]), dims=1),
    facies=ValidationPrerun.facies(feedback))

function main()
    run_model(Model{ALCAP}, input(true), "$OUTPUT_FILE")
end

function plot()

    fig = Figure(size=(20cm, 12cm), fontsize=8pt)
    ax1 = Axis(fig[1,1], title="sediment profile")
    ax2 = Axis(fig[1,2], title="interpreted seismic profile")
    header, data = read_slice("$OUTPUT_FILE", :profile)
	sediment_profile!(ax1, header, data, show_coeval_lines = true, show_unconformities = true)
    save("md/fig/validation_comparison_dt250.png", fig, px_per_unit=3)
end


result = Validation.main()
Validation.plot()

end