# ~/~ begin <<md/paper.md#variable_SL>>[init]
#| id: variable_SL
#| file: runs/variable_sl.jl
#| creates: data/variableSL.h5

using CarboKitten

module VariableSL

using ..ALCAP: ALCAP
using CarboKitten.Boxes: Box, Coast
using CarboKitten.Config: TimeProperties
using CarboKitten.Components.H5Writer: OutputSpec
using Unitful
using CarboKitten.DataSets: miller_2020
using DataFrames
using Interpolations

miller_df = miller_2020()
miller_df = filter(r -> r.reference == "Lisiecki et al. 2005", miller_df)
sort!(miller_df, [:time])
miller_sea_level = linear_interpolation(miller_df.time, miller_df.sealevel);

const PATH = "data/"

const TAG = "variable_sea_level"

const FACIES = [
    ALCAP.Facies(
        viability_range = (4, 10),
        activation_range = (6, 10),
        maximum_growth_rate=200u"m/Myr",
        extinction_coefficient=0.8u"m^-1",
        saturation_intensity=60u"W/m^2",
        diffusion_coefficient=50.0u"m/yr"),
    ALCAP.Facies(
        viability_range = (4, 10),
        activation_range = (6, 10),
        maximum_growth_rate=400u"m/Myr",
        extinction_coefficient=0.1u"m^-1",
        saturation_intensity=60u"W/m^2",
        diffusion_coefficient=25.0u"m/yr"),
    ALCAP.Facies(
        viability_range = (4, 10),
        activation_range = (6, 10),
        maximum_growth_rate=100u"m/Myr",
        extinction_coefficient=0.005u"m^-1",
        saturation_intensity=60u"W/m^2",
        diffusion_coefficient=12.5u"m/yr")
]

const INPUT = ALCAP.Input(
    tag="$TAG",
    box=Box{Coast}(grid_size=(100, 50), phys_scale=150.0u"m"),
    time=TimeProperties(
        Δt=0.1u"kyr",
        steps=10270),
    output=Dict(
        :profile => OutputSpec(slice=(:, 25), write_interval=2)),
    ca_interval=1,
    initial_topography=(x, y) -> -x / 300.0,
    sea_level=t -> miller_sea_level(t - 5320.92*u"kyr"), # this magic number is the oldest date in Lisiecki et al. 2005
    subsidence_rate=50.0u"m/Myr",
    disintegration_rate=50.0u"m/Myr",
    insolation=400.0u"W/m^2",
    sediment_buffer_size=50,
    depositional_resolution=0.5u"m",
    facies=FACIES)

end

CarboKitten.init()
CarboKitten.run_model(Model{ALCAP}, VariableSL.INPUT, "data/variableSL.h5")
# ~/~ end