# ~/~ begin <<md/paper.md#runs/standard_example_plot.jl>>[init]
#| file: runs/standard_example_plot.jl
#| classes: ["task"]
#| requires: data/alcap-example.h5
#| creates: md/fig/summary-plot.png
#| collect: figures
module StandardExamplePlot
using CairoMakie
using CarboKitten.Visualization: summary_plot

function main()
    fig = summary_plot("data/alcap-example.h5")
    save("md/fig/summary-plot.png", fig)
end
end

StandardExamplePlot.main()
# ~/~ end
