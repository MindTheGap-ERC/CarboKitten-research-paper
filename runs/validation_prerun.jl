# ~/~ begin <<md/paper.md#runs/validation_case.jl>>[init]
#| file: runs/validation_case.jl
#| creates: md/fig/validation.png

module ValidationPrerun

using Unitful
using CarboKitten
using Interpolations
using CairoMakie
using CarboKitten.Visualization: sediment_profile, summary_plot
using CarboKitten.Export: read_slice, read_volume, write_csv
using Tables
using CarboKitten.Boxes: Periodic

const TAG = "validation_prerun"

const OUTPUT_FILE = "data/$(TAG).h5"
const PERIOD = 0.2 * u"Myr"
const AMPLITUDE = 30.0u"m"
const BASE = 30.0u"m"

include("runs/ValidationConstants.jl")

function dome_topography(x,y)
    X_DIM = GRID_SIZE[1] * PHYS_SCALE
    Y_DIM = GRID_SIZE[2] * PHYS_SCALE
    radius = 0.2 * min(X_DIM, Y_DIM)
    center_x, center_y = 0.5 * X_DIM, 0.5 * Y_DIM
    dist = sqrt((x - center_x)^2 + (y - center_y)^2)
    if dist <= radius
        45.0u"m"
    else
        x = dist - radius
        max(-70.0u"m", 45.0u"m" - 0.1 * x)
    end
end

input(feedback) = ALCAP.Input(
    tag=TAG,
    box=VALIDATION_BOX,
    time=TimeProperties(
        Δt=0.0001u"Myr",
        steps=5000
    ),
    output=Dict(
        :topography => OutputSpec(write_interval=1000),
        :profile => OutputSpec(slice=(:, 50), write_interval=500)
    ),
    ca_interval=1,
    ca_random_seed = 0,
    initial_topography = dome_topography,
    sea_level= t -> (sin(t * 2π / PERIOD) * AMPLITUDE + BASE),
    subsidence_rate=10.0u"m/Myr",
    disintegration_rate=20.0u"m/Myr",
    insolation=400.0u"W/m^2",
    sediment_buffer_size=50,
    depositional_resolution=0.5u"m",
    lithification_time = 50.0u"yr",
    disintegration_transfer = f -> stack((f[1,:,:], 0.0.*f[2,:,:], f[3,:,:],
                                      f[1,:,:].+f[4,:,:]), dims=1),
    facies=facies(feedback))

function main()
    run_model(Model{ALCAP}, input(true), "$OUTPUT_FILE")
end

function preplot()
    header, data = read_slice("$OUTPUT_FILE", :profile)
	fig = sediment_profile(header, data, show_unconformities = false)
    save("md/fig/$(TAG).png", fig)
end
end

result = ValidationPrerun.main()
ValidationPrerun.save_final_topography(ValidationPrerun.OUTPUT_FILE)
ValidationPrerun.preplot()
# ~/~ end
