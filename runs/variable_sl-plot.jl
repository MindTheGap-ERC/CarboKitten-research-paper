# ~/~ begin <<md/paper.md#runs/variable_sl-plot.jl>>[init]
#| file: runs/variable_sl-plot.jl
#| requires: data/variableSL.h5
#| creates: md/fig/ALCAPS_profile.png
#| collect: figures

using CairoMakie
using CarboKitten.Visualization: sediment_profile
using HDF5
using CarboKitten.Export: read_slice, read_header

h5open("data/variableSL.h5") do fid
    header = read_header(fid)
    data = read_slice(fid["profile"])
    fig = sediment_profile(header, data)
    save("md/fig/ALCAPS_profile.png", fig)
end
# ~/~ end