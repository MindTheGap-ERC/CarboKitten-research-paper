---
title: CarboKitten.jl
subtitle: an open source toolkit for carbonate stratigraphy modeling
author: Johan Hidding, Emilia Jarochowska, Xianji Liu
---

:::abstract
## Abstract
:::

## Introduction

## Model

### Quantities

Subsidence rate

: Quantified as a rate $\sigma$ in units of $\textrm{m/Myr}$. The growth of sediment is only sustainable in scenarios where there is a steady subsidence. In our models we use a default value of $50 \textrm{m/Myr}$ (or $0.5 \textrm{mm/kyr}$).

Initial topography

: The model starts at an initial topography $\eta_0 = \eta(t_0)$, consisting of impenetrable bedrock.

Topography

: The present topography $\eta$ is given as the initial topgraphy plus any amount of sediment accumulated over time. In our definition of $\eta$ we don't correct for subsidence.

Relative sea level

: The relative sea level $R(t)$ is usually a function of time, given as an input parameter of the model.

Water depth

: The water depth is computed from the current topography, relative sea level and subsidence rate,

  $$w(x, t) = R(t) - \eta(x, t) + \int_{t_0}^{t} \sigma \textrm{d}t.$$

### Production

The general form of our production model follows that of @Bosscher1992 (BS92). This model finds the sediment accumulation curve by integrating an ODE that outside of the model parameters only depends on the initial topography.

$$\frac{\partial \eta}{\partial t} = P(\eta),$$

where $P$ is the sediment production in $\textrm{m/Myr}$,

$$P(w) = g_m \tanh\left(\frac{I_0 e^{-kw}}{I_k}\right),$$

where $I_0$ is the insolation, $I_k$ is the saturation intensity, $k$ the extinction coefficient and $g_m$ the maximum growth rate.

This model encapsulates both the exponential extinction of sun light as water depth increases, and the idea that the growth of organisms interpolates between no growth at great depth and saturated growth in shallow waters (i.e. solar input is not the limiting factor at those depths).

Here we parametrize $P$ as a function of $w$. Note that $\nabla w = - \nabla \eta$, but otherwise we'll use $w$ and $\eta$ wherever one or the other is more convenient.

Following @Burgess2013, we extend the BS92 model by introducing multiple facies that each have their own growth characteristics (except for insolation $I_0$, which is a global input variable).

$$P(w) = \sum_f P_f(w)$$

| Factory | $g_m$ $[\textrm{m}/\textrm{Myr}]$ | $I_k$ $[\textrm{W}/\textrm{m}^2]$ | $k$ $[\textrm{m}^{-1}]$ |
|---------|-------|-------|-----|
| Tropical | 500.0 | 60.0 | 0.8 |
| Mounds | 400.0 | 60.0 | 0.1 |
| Cool water | 100.0 | 60.0 | 0.005 |

Table: Parameters for the production model of the three default carbonate factories. {#tbl:factories}

Our default parameters define three biological facies based on sediment produced by three carbonate factories: the tropical (T), mounds (M) and cool water (C) factories. The default values for these factories are shown in Table @tbl:factories, and the resulting production curves shown in Figure @fig:factories.

![Production curves for three default carbonate factories](fig/production-curves.svg){#fig:factories width=100%}

FIXME: Add legend to figure showing which curve is Tropical, Mounds and Cool water factory.



:::hide
```julia
#| id: bs92-input
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
        steps = 5000,
        write_interval = 1),
    sea_level = t -> 4.0u"m" * sin(2π * t / 0.2u"Myr"),
    initial_topography = (x, y) -> - x / 300.0,
    subsidence_rate = 50.0u"m/Myr",
    insolation = 400.0u"W/m^2",
    facies = FACIES)
```

```julia
#| classes: ["task"]
#| creates: ["md/fig/production-curves.svg"]
#| collect: figures

module Script
using CairoMakie
using CarboKitten
using CarboKitten.Visualization: production_curve!

<<bs92-input>>

function main()
  fig = Figure()
  ax = Axis(fig[1, 1])
  production_curve!(ax, INPUT)
  save("md/fig/production-curves.svg", fig)
end

end

Script.main()
```
:::

### Cellular Automaton

### Transport

We may decompose the equation for sediment production as follows,

$$\frac{\partial \eta}{\partial t} = \term{production} + \term{disintegration} + \term{transport}$$

We consider all sediment transport to happen in a layer close to the ocean floor. This layer has a certain concentration of sediment that travels along a path of steepest descent. We say that this material is **entrained**. We set the concentration of entrained material $C_f$ to be the sum of the production rate and the disintegration rate:

$$C_f = P_f + D_f.$$

We assume a local sediment flux,

$$\vec{q}_f = - \nu_f C_f \vec{\nabla} \eta,$$

where $\nu_f$ is a facies dependent diffusion rate. The mass balance is then,

$$\begin{aligned}
\term{transport} &= -\sum_f \vec{\nabla} \cdot \vec{q}_f\\
                 &= \vec{\nabla} \cdot \left[\nu_f C_f \vec{\nabla} \eta\right].
\end{aligned}$$


## Software design

## Examples of use

## Validation

## Conclusion

