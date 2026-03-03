# ~/~ begin <<md/paper.md#runs/TransportPlots.jl>>[init]
module TransportPlots

using CarboKitten
using CairoMakie
using Unitful
using Printf

function plot_topography(result)
    fig = Figure()
    ax = Axis(fig[1, 1])
    plot_topography!(ax, result)
    fig
end

function plot_topography!(ax, result)
    diffusivity::typeof(1.0u"m/yr") = result.header.attributes[:diffusivity]
    disintegration_rate::typeof(1.0u"m/Myr") = result.header.attributes[:disintegration_rate]

    dt = result.header.Δt

    ax.xlabel = "x [km]"
    ax.ylabel = "h [m]"

    h0 = result.header.initial_topography[:,1]
    x_axis = result.header.axes.x |> in_units_of(u"km")
    slice = result.data_volumes[:all][:, 1]
    t_axis = result.header.axes.t[1:slice.write_interval:end] |> in_units_of(u"Myr")
    time_steps = div(result.header.time_steps, slice.write_interval)

    ixs = [div(time_steps, 10) + 1, div(time_steps, 2) + 1, time_steps]
    for ix in ixs
        h = (h0 .+ slice.sediment_thickness[:, ix]) |> in_units_of(u"m")
        lines!(ax, x_axis, h, label=@sprintf("%.1f", t_axis[ix]))
    end
end

function plot_matrix(plot!, results, row_names, col_names; fig_pars...)
    fig = Figure(;fig_pars...)
    nrows, ncols = size(results)
    @assert nrows == length(row_names)
    @assert ncols == length(col_names)

    for (i, c) in enumerate(col_names)
        Label(fig[i, 0], c, rotation = pi/2, tellheight=false, tellwidth=true)
    end
    for (i, r) in enumerate(row_names)
        Label(fig[0, i], r, tellheight=true, tellwidth=false)
    end
    axes = [Axis(fig[reverse(Tuple(i))...], title="($('`'+l))")
        for (l,i) in enumerate(eachindex(IndexCartesian(), results))]

    for i in eachindex(IndexCartesian(), results)
        ax = axes[i]
        if i != CartesianIndex(1, 1)
            linkyaxes!(axes[1, 1], ax)
        end
        plot!(ax, results[i])
        if i[2] != ncols
            ax.xlabel = ""
        end
        if i[1] != 1
            ax.ylabel = ""
        end
    end

    Legend(fig[:, nrows+1], axes[1, 1], "time steps [Myr]")

    return fig
end

end
# ~/~ end
