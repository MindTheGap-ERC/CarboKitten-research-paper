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
                          offset1::Tuple{Int64, Int64},
                          offset2::Tuple{Int64, Int64})
    
    panel_positions = [
        (1, 1), # a 
        (1, 3), # b 
        (2, 3), # c 
        (3, 1), # d 
        (3, 2), # e 
        (3, 3)  # f 
    ]
    
    for (i, (row, col)) in enumerate(panel_positions)
        if i <= 3   
            Label(fig[row, col], labels[i], 
                  tellwidth=false, 
                  tellheight=false,
                  halign=:left,
                  valign=:top,
                  padding=(offset1[1], offset1[1], -offset1[2], offset1[1]),
                  fontsize=fontsize)
        else 
            Label(fig[row, col], labels[i], 
                    tellwidth=false, 
                    tellheight=false,
                    halign=:left,
                    valign=:top,
                    padding=(offset2[1], offset2[1], -offset2[2], offset2[1]),
                    fontsize=fontsize)
        end
    end
    
    return fig
end


function main()
    fig = summary_plot("data/alcap-example.h5")
    add_panel_labels!(fig, labels = ["a", "b", "c", "d", "e", "f"], fontsize = 22, offset1 = (-25,-5), offset2 = (-25,10))
    save("md/fig/summary-plot.png", fig)
end
end

StandardExamplePlot.main()
# ~/~ end
