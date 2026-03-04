# ~/~ begin <<md/paper.md#runs/production-curves.jl>>[init]
module Script

using CarboKitten
using CarboKitten.Production
using CairoMakie

@kwdef struct Input <: CarboKitten.AbstractInput
    insolation = 400.0u"W/m^2"
end

inch = 96
pt = 4/3
cm = inch / 2.54

function main()
    water_depth = (0.01:0.1:50.0)u"m"
    fig = Figure(size=(8.3cm, 9.0cm), fontsize=8pt)
    input = Input()

    ax = Axis(fig[1, 1], title="production at 400.0 W m⁻²",
        yreversed=true, ylabel="depth [m]", xlabel="production [m/Myr]")
    for (k, prod) in pairs(Production.EXAMPLE)
        f = production_profile(input, prod)
        p = water_depth .|> (w -> f(input.insolation, w))
        lines!(ax, p |> in_units_of(u"m/Myr"),
            water_depth |> in_units_of(u"m"), label = string(k))
    end
    axislegend(ax, "factories", valign = :bottom)
    save("md/fig/production-curves.pdf", fig)
end

end

Script.main()
# ~/~ end
