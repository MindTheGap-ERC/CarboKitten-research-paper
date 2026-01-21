# ~/~ begin <<md/paper.md#runs/benchmark_plot.jl>>[init]
#| file: runs/benchmark_plot.jl
#| classes: ["task"]
#| requires:
#|   - data/benchmark.csv
#| creates:
#|   - md/fig/benchmark.pdf
#| collect: figures
module BenchmarkPlot

using CairoMakie
using AlgebraOfGraphics
using DataFrames
using CSV

function main()
    df = CSV.read("data/benchmark.csv", DataFrame)
    fig = Figure()

    layer1 = data(df) * mapping(:steps => "time steps", :time => "run time [s]", color=:res => string => "grid size") * visual(ScatterLines)
    layer2 = data(df) * mapping(:res => "grid size", :time => "run time [s]", color=:steps => string => "time steps") * visual(ScatterLines)

    fig = Figure(size=(800, 400))
    fg1 = draw!(fig[1, 1], layer1, axis=(xscale=Makie.pseudolog10, yscale=log10))
    legend_args = (tellwidth=false, tellheight=false, halign=:left, valign=:top, margin=(10, 10, 10, 10))
    legend!(fig[1, 1], fg1; legend_args...)
    fg2 = draw!(fig[1, 2], layer2, axis=(xscale=Makie.pseudolog10, yscale=log10))
    legend!(fig[1, 2], fg2; legend_args...)

    Label(fig[1, 1, TopLeft()], "a", halign=:left, fontsize=20)
    Label(fig[1, 2, TopLeft()], "b", halign=:left, fontsize=20)

    save("md/fig/benchmark.pdf", fig)

    fig
end

end

BenchmarkPlot.main()
# ~/~ end
