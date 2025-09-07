# ~/~ begin <<md/paper.md#runs/disintegration-vs-cementation.jl>>[init]
#| file: runs/disintegration-vs-cementation.jl
#| classes: ["task"]
#| creates:
#|   - md/fig/disintegration-vs-cementation.pdf
#| requires:
#|   - runs/TransportTest.jl
#|   - runs/TransportPlots.jl
#| collect: figures
module DisintegrationVsCementation

include("TransportPlots.jl")
include("ParameterScan.jl")
include("TransportTest.jl")

using CarboKitten
using CairoMakie
using .ParameterScan: cartesian_product
using .TransportTest: run_with
using .TransportPlots: plot_matrix, plot_topography!

function main()
    CarboKitten.init()

    pars = (
        diffusivity = [ 10.0 ] * u"m/yr",
        disintegration_rate = [ 10.0, 500.0 ] * u"m/Myr",
        dt = [ 100.0 ] * u"yr",
        cementation_time = [ 100.0, 1000.0 ] * u"yr" )
    cp = cartesian_product(;pars...)

    result = Array{Union{Missing, MemoryOutput}}(missing, size(cp)...)
    Threads.@threads for i in eachindex(cp)
        result[i] = run_with(;cp[i]...)
    end

    fig = plot_matrix(result[1,:,1,:], 
            ["dr = $(d.val) m/Myr" for d in pars.disintegration_rate],
            ["ct = $(d.val) yr" for d in pars.cementation_time];
            fontsize = 10) do ax, result
        plot_topography!(ax, result)
    end

    save("md/fig/disintegration-vs-cementation.pdf", fig)
end

end

DisintegrationVsCementation.main()
# ~/~ end