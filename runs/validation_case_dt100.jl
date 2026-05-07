module Validation

using Unitful
using CarboKitten
using Interpolations
using CairoMakie
using Tables
using CarboKitten.Export: read_volume
using CarboKitten.Boxes: Box


const TAG = "validation_dt100"
const PRERUN = "data/validationprerun.h5"

include("ValidationConstants.jl")

input(feedback) = ALCAP.Input(
    tag="$TAG",
    box=ValidationConstants.VALIDATION_BOX,
    time=TimeProperties(
        t0 = -15.48u"Myr",
        Δt=100u"yr",
        steps=40000),
    output=Dict(
        :topography => OutputSpec(write_interval = 1000),
        :profile => OutputSpec(slice=(:, 50), write_interval=1)),
    ca_interval=40,
    ca_random_seed = 1,
    initial_topography = ValidationConstants.add_final_topography("data/validationprerun.h5"), 
    sea_level=ValidationConstants.sea_level(ValidationConstants.FILEPATH),
    subsidence_rate=150.0u"m/Myr",
    transport_solver = Val{:forward_euler},
    disintegration_rate=50.0u"m/Myr",
    insolation=400.0u"W/m^2",
    sediment_buffer_size=50,
    depositional_resolution=0.5u"m",
    lithification_time = 100.0u"yr",
    disintegration_transfer = f -> stack((f[1,:,:], 0.0.*f[2,:,:], f[3,:,:],
                                      f[2,:,:].+f[4,:,:]), dims=1),
    facies=ValidationConstants.facies(feedback))

function main()
    run_model(Model{ALCAP}, input(true), "data/$(TAG).h5")
end

result = Validation.main()
ValidationConstants.plot(TAG)

end