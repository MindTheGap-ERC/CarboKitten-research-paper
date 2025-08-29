# ~/~ begin <<md/paper.md#runs/standard_example_plot.jl>>[init]
#| file: runs/standard_example_plot.jl
#| classes: ["task"]
#| requires: data/alcap-example.h5
#| creates: md/fig/summary-plot.png
#| collect: figures
module StandardExamplePlot
using CairoMakie
using CarboKitten.Visualization: summary_plot

function add_panel_labels!(fig::Figure; 
                          labels::Vector{String}, 
                          fontsize::Int64,
                          offset::Tuple{Int64, Int64})
    
    panel_positions = [
        (1, 1), # a 
        (1, 3), # b 
        (2, 3), # c 
        (3, 1), # d 
        (3, 2), # e 
        (3, 3)  # f 
    ]
    
    for (i, (row, col)) in enumerate(panel_positions)
        if i <= length(labels)   
            Label(fig[row, col], labels[i], 
                  tellwidth=false, 
                  tellheight=false,
                  halign=:left,
                  valign=:top,
                  padding=(offset[1], offset[1], -offset[2], offset[1]),
                  fontsize=fontsize)
        end
    end
    
    return fig
end


function main()
    fig = summary_plot("data/alcap-example.h5")
    add_panel_labels!(fig, labels = ["a", "b", "c", "d", "e"], fontsize = 18, offset = (5,-3))
    save("md/fig/summary-plot.png", fig)
end
end

StandardExamplePlot.main()
# ~/~ end
