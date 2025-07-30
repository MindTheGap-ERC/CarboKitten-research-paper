# ~/~ begin <<md/paper.md#runs/atoll-map-plot.jl>>[init]
#| file: runs/atoll-map-plot.jl
#| classes: ["task"]
#| requires: data/atoll.h5
#| creates: md/fig/atoll-map.png
#| collect: figures
using HDF5
using CairoMakie
using CarboKitten.Export: read_header

h5open("data/atoll.h5") do fid
    h = read_header(fid)
    s = fid["topography"]["sediment_thickness"][:, :, end] * u"m"
    t = h.initial_topography .+ s .- (h.axes.t[end] * h.subsidence_rate)

    fig = Figure()
    ax = Axis(fig[1, 1], limits=((3.0, 12.0), (3.0, 12.0)), aspect=DataAspect())
    hm = heatmap!(ax, h.axes.x, h.axes.y, t / u"m", colorrange=(-10, 10), colormap=Reverse(:RdBu_8))
    Colorbar(fig[1, 2], hm)

    save("md/fig/atoll-map.png", fig)
end
# ~/~ end