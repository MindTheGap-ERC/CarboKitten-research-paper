# ~/~ begin <<md/paper.md#runs/topologies.jl>>[init]
#| file: runs/topologies.jl
module TopologyRuns

using CarboKitten
using CarboKitten.Models: ALCAP as M

function main()
    facies = [
        M.Facies(),
        M.Facies(),
        M.Facies()
    ]

    coast_input = M.Input(
        time = TimeProperties(),
        box = Box{Coast}(grid_size=(50, 50), phys_scale=150.0u"m"),
        facies = facies
    )
end

end

TopologyRuns.main()
# ~/~ end