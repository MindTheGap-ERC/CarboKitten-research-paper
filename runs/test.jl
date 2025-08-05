using CarboKitten
using CarboKitten.Export: read_data, read_volume
using Unitful
using CarboKitten.Export: extract_wd
using CairoMakie
using CarboKitten.Visualization: sediment_profile

header, data = read_volume("data/var_sl.h5", :full)
extract_wd(header, data[100,50], true)
fig = sediment_profile(header, data[:,25])

