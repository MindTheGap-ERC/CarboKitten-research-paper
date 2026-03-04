# ~/~ begin <<md/paper.md#runs/production-curves.jl>>[init]

module Script
using CairoMakie
using CarboKitten
using CarboKitten.Visualization: production_curve!

# ~/~ begin <<md/paper.md#bs92-input>>[init]
const FACIES = [
    BS92.Facies(
         maximum_growth_rate=500u"m/Myr"/4,
         extinction_coefficient=0.8u"m^-1",
         saturation_intensity=60u"W/m^2"),
    BS92.Facies(
         maximum_growth_rate=400u"m/Myr"/4,
         extinction_coefficient=0.1u"m^-1",
         saturation_intensity=60u"W/m^2"),
    BS92.Facies(
         maximum_growth_rate=100u"m/Myr"/4,
         extinction_coefficient=0.005u"m^-1",
         saturation_intensity=60u"W/m^2")]

const INPUT = BS92.Input(
    tag = "example model BS92",
    box = CarboKitten.Box{Coast}(grid_size=(100, 1), phys_scale=150.0u"m"),
    time = TimeProperties(
        Δt = 200.0u"yr",
        steps = 5000),
    sea_level = t -> 4.0u"m" * sin(2π * t / 0.2u"Myr"),
    initial_topography = (x, y) -> - x / 300.0,
    subsidence_rate = 50.0u"m/Myr",
    insolation = 400.0u"W/m^2",
    facies = FACIES)
# ~/~ end

inch = 96
pt = 4/3
cm = inch / 2.54

function main()
  fig = Figure(size=(8.3cm, 9.0cm), fontsize=8pt)
  ax = Axis(fig[1, 1])
  production_curve!(ax, INPUT)
  ax.scene.plots[1].label = "euphotic"
  ax.scene.plots[2].label = "oligophotic"
  ax.scene.plots[3].label = "aphotic"
  axislegend(ax, "factories", valign = :bottom)
  save("md/fig/production-curves.pdf", fig)
end

end

Script.main()
# ~/~ end
