# ~/~ begin <<md/paper.md#variable_SL>>[init]
module VariableSL

using CarboKitten
using DelimitedFiles: readdlm
using Unitful
using DataFrames
using Interpolations
using CategoricalArrays
using CarboKitten.DataSets: artifact_dir
using CairoMakie
using CarboKitten.Visualization: sediment_profile!
using CarboKitten.Export: read_slice

function miller_2020()
    dir = artifact_dir()
    filename = joinpath(dir, "Miller2020", "Cenozoic_sea_level_reconstruction.tab")

    data, header = readdlm(filename, '\t', header=true)
    return DataFrame(
        time=-data[:,4] * u"kyr",
        sealevel=data[:,7] * u"m",
        refkey=categorical(data[:,2]),
        reference=categorical(data[:,3]))
end

function sea_level()
    df = miller_2020()
    lisiecki_df = df[df.refkey .== "846 Lisiecki", :]
    lisiecki_df = filter(row -> -2.0u"Myr" <= row.time, lisiecki_df)
    sort!(lisiecki_df, [:time])

    return linear_interpolation(
        lisiecki_df.time,
        lisiecki_df.sealevel)
end

const TIME_PROPERTIES = TimeProperties(
    t0 = -1999.7u"kyr",
    Δt = 100.0u"yr",
    steps = 18650
)

const TAG = "lisiecki-sea-level"

const FACIES = [
    ALCAP.Facies(
        production=BenthicProduction(
            maximum_growth_rate=200u"m/Myr",
            extinction_coefficient=0.8u"m^-1",
            saturation_intensity=60u"W/m^2"),
        transport_coefficient=20.0u"m/yr",
        name="euphotic"),
    ALCAP.Facies(
        production=BenthicProduction(
            maximum_growth_rate=500u"m/Myr",
            extinction_coefficient=0.1u"m^-1",
            saturation_intensity=60u"W/m^2"),
        transport_coefficient=10.0u"m/yr",
        name="oligophotic"),
    ALCAP.Facies(
        production=BenthicProduction(
            maximum_growth_rate=100u"m/Myr",
            extinction_coefficient=0.005u"m^-1",
            saturation_intensity=60u"W/m^2"),
        transport_coefficient=50.0u"m/yr",
        name="aphotic")
]

const INPUT = ALCAP.Input(
    tag="$TAG",
    box=CarboKitten.Box{Coast}(grid_size=(200, 50), phys_scale=150.0u"m"),
    time=TIME_PROPERTIES,
    ca_interval=1,
    initial_topography=(x, y) -> -x / 200.0 + 20.0u"m",
    sea_level=sea_level(),
    output=Dict(
        :profile => OutputSpec(slice = (:, 25), write_interval = 1)),
    subsidence_rate=5.0u"m/Myr",
    disintegration_rate=50.0u"m/Myr",
    insolation=500.0u"W/m^2",
    sediment_buffer_size=50,
    depositional_resolution=0.5u"m",
    facies=FACIES)

function main()
    CarboKitten.init()
    run_model(Model{ALCAP}, INPUT, "data/variable-sl.h5")
end

function plot(result_file)
    header, result_profile = read_slice(result_file, :profile)

    inch = 96
    pt = 4/3
    cm = inch / 2.54

    fig = Figure(size=(20cm, 12cm), fontsize=8pt)
    ax_left = Axis(fig[1, 1])
    ax_right = Axis(fig[1, 2])
    colsize!(fig.layout, 1, Relative(0.2))
    Label(fig[1, 1, TopLeft()], "(a)")
    Label(fig[1, 2, TopLeft()], "(b)")

    sl_fn = sea_level()
    times = collect(time_axis(TIME_PROPERTIES))
    sl_values = [ustrip(u"m", sl_fn(t)) for t in times]
    times_myr = ustrip.(u"Myr", times)

    lines!(ax_left, sl_values, times_myr)
    ax_left.xlabel = "Sea level [m]"
    ax_left.ylabel = "Time [Myr]"

    sediment_profile!(ax_right, header, result_profile, show_unconformities=50)

    save("md/fig/variable-sl.png", fig, px_per_unit=300/inch)
end

end

# result = VariableSL.main()
result = "data/variable-sl.h5"
VariableSL.plot(result)
# ~/~ end
