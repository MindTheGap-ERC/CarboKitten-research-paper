# ~/~ begin <<md/paper.md#runs/atoll-profile-plot.jl>>[init]
#| file: runs/atoll-profile-plot.jl
#| classes: ["task"]
#| requires: data/atoll.h5
#| creates: md/fig/atoll-profile.png
#| collect: figures

using CairoMakie
using CarboKitten.Visualization: sediment_profile
using HDF5
using CarboKitten.Export: read_slice, read_header

h5open("data/atoll.h5") do fid
    header = read_header(fid)
    data = read_slice(fid["profile"])
    fig = sediment_profile(header, data)
    save("md/fig/atoll-profile.png", fig)
end
# ~/~ end