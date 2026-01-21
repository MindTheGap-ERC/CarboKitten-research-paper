# ~/~ begin <<md/paper.md#runs/topology_plot.jl>>[init]
#| file: runs/topology_plot.jl
#| classes: ["task"]
#| creates:
#|   - md/fig/topologies.png
#| requires:
#|   - data/topology_coast.h5
#|   - data/topology_periodic.h5
#| collect: figures
module TopologyPlot

using CairoMakie
using CarboKitten.Export: read_volume
using CarboKitten.Visualization: glamour_view!

function main()
    coastal_header, coastal_data =
        read_volume("data/topology_coast.h5", :topography)
    periodic_header, periodic_data =
        read_volume("data/topology_periodic.h5", :topography)

    fig = Figure(size=(800, 500))

	glamour_view!(
        Axis3(fig[1, 1], title="(a) periodic boundaries",
              width=250, height=250),
        periodic_header, periodic_data,
        colormap=Reverse(:GnBu))

	glamour_view!(
        Axis3(fig[1, 2], title="(b) coastal boundaries"),
        coastal_header, coastal_data,
        colormap=Reverse(:GnBu))

	ax1 = Axis(fig[2, 1], title="(c)", aspect=1.0)
	hlines!(ax1, [0.0, 15.0])
	vlines!(ax1, [0.0, 15.0])
	arrows2d!(ax1,
			  [Point(7.5, 0.0), Point(7.5, 15.0),
			   Point(0.0, 7.5), Point(15.0, 7.5)],
			  [Vec(0.0, 2.0), Vec(0.0, 2.0),
			   Vec(2.0, 0.0), Vec(2.0, 0.0)],
			  color=[:red, :red, :blue, :blue])

	ax2 = Axis(fig[2, 2], title="(d)", aspect=DataAspect(), height=100)
	hlines!(ax2, [0.0, 5.0])
	vlines!(ax2, [0.0, 15.0])
	arrows2d!(ax2,
			  [Point(7.5, 0.0), Point(7.5, 5.0),
			   Point(0.0, 2.5), Point(0.0, 2.5),
			   Point(15.0, 2.5), Point(15.0, 2.5)],
			  [Vec(0.0, 0.8), Vec(0.0, 0.8),
			   Vec(1.0, 0.0), Vec(-1.0, 0.0),
			   Vec(1.0, 0.0), Vec(-1.0, 0.0)],
			  color=[:red, :red, :blue, :blue, :green, :green])

    save("md/fig/topologies.png", fig)
    return fig
end

end

TopologyPlot.main()
# ~/~ end
