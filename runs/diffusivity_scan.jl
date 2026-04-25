# ~/~ begin <<md/paper.md#runs/diffusivity_scan.jl>>[init]
using CarboKitten
using CarboKitten.Models: ALCAP as M
using CairoMakie
using Unitful: ustrip, unit, NoUnits
using DelimitedFiles

include("diffusivity_estimation.jl")

box = CarboKitten.Box{Periodic{2}}(grid_size=(100, 1), phys_scale=50.0u"m")

t_end = 1.0u"Myr"
Δt = 50.0u"yr"
t_steps = t_end / Δt |> ceil |> Int
peak_centre = box.phys_scale * box.grid_size[1] ÷ 2
peak_width = 200.0u"m"
peak_height = 10.0u"m"
write_interval = max(1, t_steps ÷ 1000)

facies1 = M.Facies(
	viability_range = (0, 0),
	activation_range = (0, 0),
	production = BenthicProduction(
		maximum_growth_rate = 0u"m/Myr",
		extinction_coefficient = 0u"m^-1",
		saturation_intensity = 60u"W/m^2"),
	transport_coefficient = 5u"m/yr",
	wave_velocity = _ -> (Vec2(0.0u"m/Myr", 0.0u"m/Myr"), Vec2(0.0u"1/Myr", 0.0u"1/Myr")),
	initial_sediment = (x, _) -> peak_height * exp(-(x - peak_centre)^2/(2 * peak_width^2)),
)

function make_input(; cementation_time, disintegration_rate)
	M.Input(
		facies = [facies1],
		box = box,
		time = TimeProperties(Δt=Δt, steps=t_steps),
		output = Dict(:profile => OutputSpec(slice=(:, 1), write_interval=write_interval)),
		lithification_time = cementation_time,
		disintegration_rate = disintegration_rate,
		subsidence_rate = 0.0u"m/Myr",
		sea_level = _ -> 0.0u"m",
		initial_topography = (_, _) -> -100.0u"m",
		insolation = 0.0u"W/m^2",
		transport_solver = Val{:forward_euler},
		depositional_resolution = 1.0u"km",
		sediment_buffer_size = 2,
	)
end

parameters = Dict(
	:cementation_time    => [1000, 2500, 5000] .* u"yr",
	:disintegration_rate => [5.0, 10.0, 20.0, 50.0] .* u"m/Myr",
)

function cartesian_product(pars::Dict{Key,Vector}) where {Key}
	if isempty(pars)
		return [ Dict{Key, Any}() ]
	end
	pars = copy(pars)
	result = []
	k, vs = first(pairs(pars))
	for item in cartesian_product(delete!(pars, k))
		for v in vs
			push!(result, merge(item, Dict(k => v)))
		end
	end
	return result
end

ct_values = parameters[:cementation_time]
dr_values = parameters[:disintegration_rate]
D_values   = Matrix{Any}(undef, length(ct_values), length(dr_values))

for (i_ct, ct) in enumerate(ct_values)
	for (i_dr, dr) in enumerate(dr_values)
		inp    = make_input(cementation_time=ct, disintegration_rate=dr)

		output = run_model(Model{M}, inp, MemoryOutput(inp))

		fig = Figure()
		ax  = Axis(fig[1, 1])
		x   = output.header.axes.x |> in_units_of(u"km")
		y   = output.data_slices[:profile].sediment_thickness |> in_units_of(u"m")
		for i in [1, 100, 1000]
			lines!(ax, x, y[:, i])
		end

		ct_val = round(Int, ustrip(u"yr", ct))
		dr_val = round(ustrip(u"m/Myr", dr), digits=2)
		save("data/diffusivity_scan/ct_$(ct_val)yr_dr$(dr_val)mMyr.png", fig)

		est = DiffusivityEstimation.estimate_diffusivity(output, use_active_layer=false)
		D_values[i_ct, i_dr] = est.D
	end
end

# strip units for plotting
D_unit   = unit(first(D_values))
D_matrix = ustrip.(D_values)
ct_axis  = ustrip.(u"yr",   ct_values)
dr_axis  = ustrip.(u"m/Myr", dr_values)

# save D_matrix to CSV: rows = cementation_time, cols = disintegration_rate
open("data/diffusivity_scan/D_matrix.csv", "w") do io
    write(io, "cementation_time_yr," * join(["dr_$(d)mMyr" for d in dr_axis], ",") * "\n")
    for (i, ct) in enumerate(ct_axis)
        write(io, "$(ct)," * join(D_matrix[i, :], ",") * "\n")
    end
end

fig_summary = Figure()
ax = Axis(fig_summary[1, 1],
	xlabel = "cementation time [yr]",
	ylabel = "disintegration rate [m/Myr]",
	title  = "Estimated diffusion coefficient for diffusivity = $(facies1.transport_coefficient)",
    aspect = length(ct_axis) / length(dr_axis))
hm = heatmap!(ax, ct_axis, dr_axis, D_matrix)
Colorbar(fig_summary[1, 2], hm, label = "D [$D_unit]")
save("data/diffusivity_scan/D_summary.png", fig_summary)
# ~/~ end
