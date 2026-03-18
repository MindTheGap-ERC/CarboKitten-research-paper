# ~/~ begin <<md/paper.md#runs/atoll-map-plot.jl>>[init]
module AtollMapPlot

using HDF5
using Unitful
using CairoMakie
using CarboKitten: in_units_of
using CarboKitten.Visualization: sediment_profile!
using CarboKitten.Export: read_volume, read_slice

inch = 96
pt = 4/3
cm = inch / 2.54

function topography!(ax, header, data; colormap=:nuuk, levels=[-10, -5, 0, 5, 10])
    ax.aspect = DataAspect()

    h = header
    s = data.sediment_thickness[:, :, end]
    t = h.initial_topography .+ s .- (h.axes.t[end] * h.subsidence_rate)
    hm = contourf!(
        ax,
        h.axes.x |> in_units_of(u"km"),
        h.axes.y |> in_units_of(u"km"),
        t / u"m", levels=levels, colormap=colormap, extendlow=:auto, extendhigh=:auto)

    contour!(
        ax,
        h.axes.x |> in_units_of(u"km"),
        h.axes.y |> in_units_of(u"km"),
        t / u"m", levels=levels, color=:black, labels=true)
    return hm
end

function main()
    fig = Figure(size=(20cm, 12cm), fontsize=8pt)

    res= 150
    levels = -5:2
    limits = (5.5, 9.5)
    tics = 5:9

    kwargs = (
        limits=(limits, limits), aspect=DataAspect(),
        xticks=tics, yticks=tics, xlabel="x [km]", ylabel="y [km]")
    ax1 = Axis(fig[1, 1], title="(a) no onshore transport"; kwargs...)
    h1, d1 = read_volume("data/atoll_$(res)_none.h5", :topography)
    ax2 = Axis(fig[1, 2], title="(b) constant velocity"; kwargs...)
    h2, d2 = read_volume("data/atoll_$(res)_flat.h5", :topography)
    ax3 = Axis(fig[1, 3], title="(c) depth dependent velocity"; kwargs...)
    h3, d3 = read_volume("data/atoll_$(res)_prof.h5", :topography)

    _, p1 = read_slice("data/atoll_$(res)_none.h5", :profile)
    ax4 = Axis(fig[2,1], title="(d)")
    _, p2 = read_slice("data/atoll_$(res)_flat.h5", :profile)
    ax5 = Axis(fig[2,2], title="(e)")
    _, p3 = read_slice("data/atoll_$(res)_prof.h5", :profile)
    ax6 = Axis(fig[2,3], title="(f)")

    hm1 = topography!(ax1, h1, d1, levels=levels)
    topography!(ax2, h2, d2, levels=levels)
    topography!(ax3, h3, d3, levels=levels)
    Colorbar(fig[1, 4], hm1, label="height [m]")
    sediment_profile!(ax4, h1, p1)
    sediment_profile!(ax5, h2, p2)
    sediment_profile!(ax6, h3, p3)

    ax4.title = "(d)"
    ax4.limits = ((3, 12), (-100, 5))
    ax5.title = "(e)"
    ax5.limits = ((3, 12), (-100, 5))
    ax6.title = "(f)"
    ax6.limits = ((3, 12), (-100, 5))
    save("md/fig/atoll-map.png", fig)
end

end

AtollMapPlot.main()
# ~/~ end
