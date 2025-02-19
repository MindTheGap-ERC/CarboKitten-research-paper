---
title: CarboKitten.jl
subtitle: an open source toolkit for carbonate stratigraphy modeling
author: Johan Hidding, Emilia Jarochowska, Xianji Liu
---

\newcommand{\term}[1]{\left(\frac{\partial \eta}{\partial t}\right)_{\textrm{#1}}}

:::abstract
## Abstract
:::

## Introduction

## Model

### Quantities

Subsidence rate

: Quantified as a rate $\sigma$ in units of $\textrm{m/Myr}$. The growth of sediment is only sustainable in scenarios where there is a steady subsidence. In our models we use a default value of $50 \textrm{m/Myr}$ (or $0.5 \textrm{mm/kyr}$).

Initial topography

: The model starts at an initial topography $\eta_0(x) = \eta(x, t_0)$, consisting of impenetrable bedrock.

Topography

: The present topography $\eta(x, t)$ is given as the initial topgraphy plus any amount of sediment accumulated over time. In our definition of $\eta$ we don't correct for subsidence (see also the definition for water depth below).

Relative sea level

: The relative sea level $R(t)$ is usually a function of time, given as an input parameter of the model.

Water depth

: The water depth is computed from the current topography, relative sea level and subsidence rate,

  $$w(x, t) = R(t) - \eta(x, t) + \int_{t_0}^{t} \sigma \textrm{d}t.$$

### Carbonate Production

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

The Celullar Automaton (CA) in CarboKitten is a direct reimplementation of the one described by @Burgess2013 in their package CarboCAT.

The CA emulates the biological succession of species by following a set of simple rules. If conditions are right, a species will multiply and occupy neighbouring territory. However, when there are too many of the same kind, the species will die from over population.

For each cell in the grid a centered neighbourhood of $5\times 5$ pixels is considered. We count the number of neighbouring cells of the same species. Then we consider two ranges: the *activation range* (default $6 \le n \le 10$) and *viability range* (default $4 \le n \le 10$). If the number of live neighbours is in the viability range, the cell stays alive. If the cell was dead, but the number of live neighbours is in the activation range, the cell becomes alive.

Since a dead cell may qualify to become alive for different carbonate factories at the same time, birth priority is rotated every iteration.

In the default configuration we emulate three species, corresponding to the Tropical, Mound and Cool water species discussed in the section on carbonate production. The state of the CA determines which carbonate factory is switched on for each cell in the grid.

:::hide
```julia
#| classes: ["task"]
#| creates: ["md/fig/ca-first-steps.svg"]
#| collect: figures

module Script
using CarboKitten
using CarboKitten.Components: CellularAutomaton as CA
using CairoMakie

function main()
  input = CA.Input(
      box = CarboKitten.Box{Periodic{2}}(
        grid_size=(50, 50), phys_scale=1.0u"m"),
      facies = fill(CA.Facies(), 3)
  )

  state = CA.initial_state(input)
  step! = CA.step!(input)
  
  fig = Figure(size=(1000, 500))
  axes_indices = Iterators.flatten(eachrow(CartesianIndices((2, 4))))
  xaxis, yaxis = box_axes(input.box)
  for (i, idx) in enumerate(axes_indices)
    ax = Axis(fig[Tuple(idx)...], aspect=AxisAspect(1), title="step $(i)")
    if idx[1] == 2
      ax.xlabel = "x [m]"
    end
    if idx[2] == 1
      ax.ylabel = "y [m]"
    end
    heatmap!(ax, xaxis/u"m", yaxis/u"m", state.ca)
    step!(state)
  end
  save("md/fig/ca-first-steps.svg", fig)
end

end

Script.main()
```

```julia
#| classes: ["task"]
#| creates: ["md/fig/ca-long-term.svg"]
#| collect: figures
module Script
using CarboKitten
using CarboKitten.Components: CellularAutomaton as CA
using CairoMakie

function main()
  input = CA.Input(
      box = CarboKitten.Box{Periodic{2}}(
        grid_size=(50, 50), phys_scale=1.0u"m"),
      facies = fill(CA.Facies(), 3)
  )

  state = CA.initial_state(input)
  step! = CA.step!(input)

  for _ in 1:1000
    step!(state)
  end
  
  fig = Figure(size=(1000, 500))
  axes_indices = Iterators.flatten(eachrow(CartesianIndices((2, 4))))
  xaxis, yaxis = box_axes(input.box)
  i = 1000
  for row in 1:2
    for col in 1:4
      ax = Axis(fig[row, col], aspect=AxisAspect(1), title="step $(i)")
      
      if row == 2
        ax.xlabel = "x [m]"
      end
      if col == 1
        ax.ylabel = "y [m]"
      end

      heatmap!(ax, xaxis/u"m", yaxis/u"m", state.ca)
      step!(state)
      i += 1
    end
    for _ in 1:996
      step!(state)
      i += 1
    end
  end
  save("md/fig/ca-long-term.svg", fig)
end

end

Script.main()
```
:::

![CA](fig/ca-long-term.svg){width=100%}

Figure: Iterations of the CA, as described by @Burgess2013, on a periodic grid of $50\times50$. Starting with random noise, we first iterate 1000 times to get into a typical state. The top row shows iterations 1000 to 1003, the bottom row 2000 to 2003. This shows that the patterns keep reasonably stable on the short term, while evolving more extensively over the long term. {#fig:ca}
 
### Transport

Our transport model is borrowed from other similar approaches in siliclastic (river bed) modeling [See @Paola1992; @James2010], where it is made plausible that this approach is viable for models that work on long time scales.

In the following, we may decompose the equation for sediment production as follows,

$$\frac{\partial \eta}{\partial t} = \term{production} + \term{disintegration} + \term{transport}$$

We consider all sediment transport to happen in an **active layer** close to the ocean floor. This layer has a certain concentration of sediment that travels along a path of steepest descent. We say that this material is **entrained**. We set the concentration of entrained material $C_f$ to be the sum of the production rate and the disintegration rate:

$$C_f = P_f + D_f.$$

We assume a local sediment flux,

$$\vec{q}_f = - \nu_f C_f \vec{\nabla} \eta,$$

where $\nu_f$ is a facies dependent diffusion rate. The mass balance is then,

$$\begin{aligned}
\term{transport} &= -\sum_f \vec{\nabla} \cdot \vec{q}_f\\
                 &= \vec{\nabla} \cdot \left[\nu_f C_f \vec{\nabla} \eta\right].
\end{aligned}$$

This is an advection equation for $C_f$ but also a diffusion equation in terms of $\eta$.

Other carbonate models like @Warrlich2000 take a very different approach, where matter is transported from unstable slopes to the nearest down slope stable region. This method is motivated by critical angle theory [@Kenter1990].

The problem with this method of transport is that production across an unstable region all is deposited on a small strip where slopes are below the critical angle. To resolve this, smaller time steps need to be taken, which hurts performance.

One aspect of critical angle theory that we do use, is that we modulate the disintegration rate (and therefore the amount of entrained material) with the magnitude of the slope $|\nabla \eta|$.

### Composed model

Putting everything together, we evaluate the model as follows each iteration:

1. Advance the cellular automaton.
2. Compute the production $P_f$.
3. Disintegrate sediment $D_f$.
4. Transport entrained sediment $C_f$.
5. Deposit entrained sediment.

Advancing the CA can be configured to happen one-in-$n$ iterations to slow it down. Transporting the sediment can be computed on smaller time steps if required for numeric stability.

## Software design

### Box topology

FIXME: give examples of runs with coast and island topologies.

### The sediment buffer

In our models of sediment transport and denudation it is important to remember the sedimentation history for all produced facies for some time into the past. We keep a three-dimensional fixed size buffer, where two dimensions represent the $x$ and $y$ coordinates of the system, and the third dimension discretizes the amount of deposited material. Each cell in the buffer represents a parcel of sediment, where we store the relative fractions of each contributing facies. We'd like to emphasise that this buffer is only used to determine the facies composition of disintegrated sediment. The sediment output of the overall model is written to disk at each iteration for post-analysis, but is no longer an active component in the model. This means that the model output can be much more precise than the depositional resolution of the buffer.

While the sediment buffer is allocated as a single 4-dimensional array (depth, facies, $x$, $y$), it is best to explain its functioning from the perspective of a single cell in our model. We are left with two dimensions: depth (rows) and facies (columns).

We choose to have the head of our sediment stack always be at the first row. When sediment out-grows the buffer, the deepest layers are dropped from memory. The head can contain an incomplete amount of sediment, while all rows below the head are either full or empty. When sediment is pushed to the stack and the head row overflows, all rows are copied down one row and the surplus is assigned to the now empty head row. The inverse happens when removing (popping) material from the stack. This process is illustrated below in Figure @fig:sediment-buffer.

![Sediment buffer diagram](fig/sediment-buffer.svg){width=100%}

Figure: Above we see a buffer. First we push a parcel of size $3/4$, then we pop an amount of $1/2$. This popped parcel will have different fractions from the pushed one, since it also draws from the half filled row that was in the stack before pushing. In this sense, a small amount of facies mixing will take place, depending on the depositional resolution chosen. {#fig:sediment-buffer}

Our implementation is such that each cell in the buffer is contiguous in memory. Thus, copying rows of unstrided memory should be very efficient, although the performance remains to be tested (FIXME).

### User interface

The user interfaces CarboKitten by writing a Julia script that defines  the relevant model parameters and  runs the chosen model. Effectively, very little Julia needs to be known to take an example input and modify parameters. Output is written to HDF5 files for post-processing and visualization.

CarboKitten ships with routines for visualisation and data extraction into CSV files. This makes it easier for novice users to use results from CarboKitten in further processing pipelines.

## Examples of use

## Validation

### Transport model

#### No production

## Conclusion

