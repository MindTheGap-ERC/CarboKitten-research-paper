# ~/~ begin <<md/paper.md#variable_SL>>[init]
#| id: variable_SL
#| file: runs/variable_sl.jl
#| creates: md/fig/fig10_variable-sl.png
module VariableSL

using CarboKitten
using DelimitedFiles: readdlm
using Unitful
using DataFrames
using Interpolations
using CategoricalArrays
using CarboKitten.DataSets: artifact_dir
using CairoMakie
using CarboKitten.Visualization: sediment_profile
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
        viability_range=(4, 10),
        activation_range=(6, 10),
        maximum_growth_rate=200u"m/Myr",
        extinction_coefficient=0.8u"m^-1",
        saturation_intensity=60u"W/m^2",
        diffusion_coefficient=20.0u"m/yr"),
    ALCAP.Facies(
        viability_range=(4, 10),
        activation_range=(6, 10),
        maximum_growth_rate=500u"m/Myr",
        extinction_coefficient=0.1u"m^-1",
        saturation_intensity=60u"W/m^2",
        diffusion_coefficient=10.0u"m/yr"),
    ALCAP.Facies(
        viability_range=(4, 10),
        activation_range=(6, 10),
        maximum_growth_rate=100u"m/Myr",
        extinction_coefficient=0.005u"m^-1",
        saturation_intensity=60u"W/m^2",
        diffusion_coefficient=50.0u"m/yr")
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

function plot(result)
    h, d = read_slice(result, :profile)
    fig = sediment_profile(h, d)
    save("md/fig/fig10_variable-sl.png", fig)
end

end

result = VariableSL.main()
VariableSL.plot(result)
# ~/~ end
