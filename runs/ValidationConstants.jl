module ValidationConstants

using Unitful
using CarboKitten
using CarboKitten.Export: read_slice, read_volume
using DelimitedFiles
using DataFrames
using Interpolations
using CarboKitten.Boxes: Box
using CairoMakie
using CarboKitten.Visualization: sediment_profile!, summary_plot


const GRID_SIZE = (140, 100)
const PHYS_SCALE = 50u"m"
const VALIDATION_BOX=Box{CarboKitten.BoundaryTrait.Periodic{2}}(grid_size=GRID_SIZE, phys_scale=PHYS_SCALE)
const FILEPATH = "data/Morley_2021.txt"

function add_final_topography(path::String)
    header, data = read_volume(path, :topography)

    t = header.axes.t
    h0 = header.initial_topography
    subsidence = header.subsidence_rate * (t[end] - t[1])
    delta_h = data.sediment_thickness[:, :, end]
    h = h0 .+ delta_h .- subsidence
    return h
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

facies(feedback) = [
    ALCAP.Facies(
        viability_range = (4, 10),
        activation_range = (6, 10),
        active = true,
        production = BenthicProduction(
            maximum_growth_rate=1800u"m/Myr",
            extinction_coefficient=0.6u"m^-1",
            saturation_intensity=60u"W/m^2"),
        transport_coefficient=2.0u"m/yr",
        name="euphotic"),
    ALCAP.Facies(
        viability_range = (4, 10),
        activation_range = (6, 10),
        active = true,
        production = BenthicProduction(
            maximum_growth_rate=800u"m/Myr",
            extinction_coefficient=0.1u"m^-1",
            saturation_intensity=60u"W/m^2"),
#        minimum_production=feedback ? 0.1u"m/Myr" : nothing,
        transport_coefficient=2.0u"m/yr",
        name="oligophotic"),
    ALCAP.Facies(
        viability_range = (4, 10),
        activation_range = (6, 10),
        active = false,
        production = PelagicProduction(
            maximum_growth_rate=8u"1/Myr",
            extinction_coefficient=0.6u"m^-1",
            saturation_intensity=60u"W/m^2",
            maximum_production_depth=50u"m"),
        transport_coefficient=2.0u"m/yr",
        name="pelagic"),
    ALCAP.Facies(
        active=false,
        transport_coefficient=2.0u"m/yr",
        name="oligophotic transported")
]

inch = 96
pt = 4/3
cm = inch / 2.54

function plot()
    fig = Figure(size=(12cm, 12cm), fontsize=8pt)
    ax1 = Axis(fig[1,1], title="sediment profile")
    header, data = read_slice("data/$(TAG).h5", :profile)
	sediment_profile!(ax1, header, data, show_coeval_lines = true, show_unconformities = true)
    save("md/fig/$TAG.png", fig, px_per_unit=3)
end

end