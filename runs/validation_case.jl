module Script

using Unitful
using CarboKitten
using CarboKitten.Export: read_slice, data_export, CSV
using DelimitedFiles
using DataFrames
using Interpolations
const PATH = "data/output"

const TAG = "alcap-validation-haldprod"
const FILEPATH = "src/input_data/Morley_2021.txt"
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

function sea_level(filepath::String)
    sealevel_data, header = readdlm(filepath,header=true)
    sealevel_data_df = DataFrame(sealevel_data,vec(header))
    Time = sealevel_data_df.Time .* 1.0u"Myr"
    Sealevel = sealevel_data_df.Sealevel .* 1.0u"m"
    sl_interpolated = LinearInterpolation(
        Time, Sealevel)
    return sl_interpolated
end

const INPUT = ALCAP.Input(
    tag="$TAG",
    box=Box{Coast}(grid_size=(100, 50), phys_scale=150.0u"m"),
    time=TimeProperties(
        Δt=0.0002u"Myr",
        steps=170000),
    output=Dict(
        :topography => OutputSpec(slice=(:,:), write_interval=50),
        :profile => OutputSpec(slice=(:, 25), write_interval=1)),
    ca_interval=10,
    initial_topography=(x, y) -> -x / 300.0,
    sea_level=sea_level(FILEPATH),
    subsidence_rate=50.0u"m/Myr",
    disintegration_rate=50.0u"m/Myr",
    insolation=400.0u"W/m^2",
    sediment_buffer_size=50,
    depositional_resolution=0.5u"m",
    facies=FACIES)

function main()
    run_model(Model{ALCAP}, INPUT, "$(PATH)/$(TAG).h5")
    header, profile = read_slice("$(PATH)/$(TAG).h5", :profile)
    columns = [profile[i] for i in 10:20:70]
    data_export(
        CSV(:sediment_accumulation_curve => "$(PATH)/$(TAG)_sac.csv",
            :age_depth_model => "$(PATH)/$(TAG)_adm.csv",
            :stratigraphic_column => "$(PATH)/$(TAG)_sc.csv",
            :water_depth => "$(PATH)/$(TAG)_wd.csv",
            :metadata => "$(PATH)/$(TAG).toml"),
         header,
         columns)
end

end

Script.main()
