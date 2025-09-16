# ~/~ begin <<md/paper.md#runs/benchmark_validation.jl>>[init]
#| file: runs/benchmark_validation.jl
module BenchmarkValidation

using CairoMakie
using CarboKitten.Visualization: sediment_profile!
using CarboKitten.Export: read_slice

function main()
    h1, d1 = read_slice("data/bench_150_2500.h5", :profile)
    h2, d2 = read_slice("data/bench_150_5000.h5", :profile)
    h3, d3 = read_slice("data/bench_150_10000.h5", :profile)

    fig = Figure(size = (1200, 400))
    sediment_profile!(Axis(fig[1, 1], title="2500 steps"), h1, d1)
    sediment_profile!(Axis(fig[1, 2], title="5000 steps"), h2, d2)
    sediment_profile!(Axis(fig[1, 3], title="10000 steps"), h3, d3)

    fig.content[1].title = "2500 steps"
    fig.content[2].title = "5000 steps"
    fig.content[3].title = "10000 steps"

    save("md/fig/fig09_benchmark_validation.png", fig)

    fig
end

end

BenchmarkValidation.main()
# ~/~ end
