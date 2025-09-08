# ~/~ begin <<md/paper.md#runs/benchmark_plot.jl>>[init]
#| file: runs/benchmark_plot.jl
#| classes: ["task"]
#| requires:
#|   - data/benchmark.csv
#| creates:
#|   - md/fig/benchmark.svg
#| collect: figures
module BenchmarkPlot

using CairoMakie
using AlgebraOfGraphics
using DataFrames
using CSV

function main()
    df = CSV.read("data/benchmark.csv", DataFrame)
    fig = Figure()

    layer1 = data(df) * mapping(:steps, :time, color=:res => string => "Grid size") * visual(ScatterLines)
    fig = draw(layer1, axis=(xscale=Makie.pseudolog10, yscale=log10))
    
    save("md/fig/benchmark.svg", fig)
end

end

BenchmarkPlot.main()
# ~/~ end
