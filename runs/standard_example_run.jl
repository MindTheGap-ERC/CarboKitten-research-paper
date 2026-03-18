# ~/~ begin <<md/paper.md#runs/standard_example_run.jl>>[init]
module StandardExample
using CarboKitten
using CarboKitten.Models: ALCAP as M

function main()
    CarboKitten.init()
    run_model(Model{M}, M.Example.INPUT, "data/alcap-example.h5")
end
end

StandardExample.main()
# ~/~ end
