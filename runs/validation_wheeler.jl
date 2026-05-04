module ValidationWheeler

using CarboKitten
using CarboKitten.Export: read_slice
using CarboKitten.Visualization: wheeler_diagram

function plot()
  header, data = read_slice("data/validation_dt100.h5", :profile)
  fig = wheeler_diagram(header, data)
  save("md/fig/wheeler_diagram.png", fig)
end

end

ValidationWheeler.plot()