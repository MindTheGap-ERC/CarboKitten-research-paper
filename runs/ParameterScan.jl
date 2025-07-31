# ~/~ begin <<md/paper.md#runs/ParameterScan.jl>>[init]
#| file: runs/ParameterScan.jl
module ParameterScan

function cartesian_product(; pars...)
    ks = keys(pars)
    vs = Iterators.product(values(pars)...)
    collect(ks .=> v for v in vs)
end

kwsplat(f) = d -> f(;d...)

end
# ~/~ end