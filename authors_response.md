# RC 1

We thank the Reviewer for constructive and encouraging feedback, which helped us improve the manuscript.

> The principal issues are

> 1. insufficient validation -- no comparison with empirical or previously published model results;

We have included an extensive validation case in the revised version, based on Henglai et al (2024) (https://doi.org/10.1016/j.marpetgeo.2024.106763).

> 2. lack of a systematic sensitivity analysis for key parameters controlling production, lithification, and diffusion;
 
We have included a discussion on the effect of these parameters. We explored the parts of the model that are novel and not used previously, for instance with a parameter scan showing linear behaviour with respect to effective dispersion rates. These rates were compared with those found in literature. More established parameters, such as production, have been used in previous models and we dedicated less space to them. A comprehensive analysis would warrant a geological interpretation and would effectively be worth a separate manuscript, which we hope to follow up with. We hope that for now the focus on the novel aspect, the transport model, will satisfy the users and invite them to explore the model.

> 3. incomplete discussion of numerical stability (CFL limits, time step guidance) and missing automatic checks; and

We have changed the text to emphasise the adaptive nature of the transport integration step, as well as implemented an additional diagnostic to check the global CFL condition during a diagnostic run.

> 4. incomplete reproducibility: figure-generation scripts and environment files are not yet linked (there is still a “FIXME” placeholder).

This was an oversight. The correct repositories and DOIs are linked now.

## General comments

> ### CA
> The description of the CA in Sect. 2.3 provides a quick overview of how ecological succession is emulated, but several aspects would benefit from clarification. First, the implementation is said to be a “direct reimplementation of Burgess (2013) CarboCAT,” yet no details are given about whether any modifications were introduced or tested (e.g., neighbourhood size, rule thresholds, asynchronous vs synchronous updating). It would be helpful to state explicitly whether the algorithm reproduces Burgess’s rules verbatim or if adjustments were made for computational or ecological reasons.

The "direct reimplementation" implies reproducing the rules proposed in Burgess (2013) verbatim. Specific questions are addressed below, but we have tested and confirmed that this set of rules is rare in that it does not saturate on a constant pattern but continues generating new patterns over long term (Fig. 2 in the manuscript). In the course of implementation, we developed an interactive simulation that allows changing the properties of the CA and observe live how they affect the patterns it produces (https://doi.org/10.5281/zenodo.18925531). This simulation supported our choice of rules as proposed by Burgess (2013), so we added a reference to it for readers interested in exploring other settings. We note that for most users the current rules will be the best and modifying the automaton would fall beyond the typical use case CarboKitten is designed for.

> In addition, please justify the choice of neighbourhood (5 x 5) and activation/viability ranges (6 ≤ n ≤ 10 and 4 ≤ n ≤ 10, respectively). Are these empirical defaults or user-defined parameters? A short sensitivity check or schematic (showing how cell states evolve under different thresholds) would clarify the model’s behaviour.

We clarified that the size of the neighborhood is currently hard-coded and selected as a compromise between degree of spatial complexity and computational costs.

> Finally, consider clarifying how birth priority rotation among factories is implemented (e.g., cyclic randomisation vs deterministic shift) and how this influences facies patterns or convergence. These details would improve transparency and reproducibility of the CA module.

The text now contains precise information how birth priority is assigned (deterministic shift). As proposed by the Reviewer, an alternative approach would be to use cyclic randomisation. Given that the priority rule only comes into play when a dead cell simultaneously qualifies for activation by multiple facies, which is a relatively rare case once the CA reaches quasi-equilibrium, we did not think a detailed discussion would be of interest for the general audience, as it relatively easy to anticipate the differences: the current approach (deterministic shift) eliminates the risk that one facies will accidentally disappear or dominate the run, which could happen if we assigned birth priority with a permutation. Permutation would, however, be aperiodic, and we did not know what "cyclic randomisation" would mean, but probably multiple implementations can be considered. The current approach introduces subtle periodicity. The current approach ensures fairness (each facies gets exactly one "first priority" turn per n_facies steps); random permutation only guarantees fairness in expectation. We did not include this level of detail in the main text to avoid making the paper more lengthy, but we added a discussion to CarboKitten's documentation.

> ### Comment on sediment buffer depth
> The manuscript clearly explains the logic and purpose of the sediment buffer (Sect. 4.2) but does not specify how the depth dimension; that is, the number of vertical layers retained in memory; is determined. It would be helpful to indicate whether this is a user-defined parameter, a fixed default value, or adaptive. Providing the typical range used in the examples (e.g., number of layers or equivalent physical thickness) would clarify the model’s temporal and vertical “memory” for sediment composition and its impact on reworking behaviour. I recommend adding this information to the methods description in Section 4.2. The authors describe the buffer as a stack, and I presume it operates under a First-In-First-Out (FIFO) data structure.

All these remarks are correct and have been worked into the text of Section 4.2.

> ### Comment on the transport model physical justification and limitations
> The active-layer finite difference transport is novel for carbonates here; the authors should more explicitly discuss the assumptions and limits (e.g., treatment of grain size, cohesive vs. non-cohesive sediments, role of storms vs background transport, lateral advection vs slope diffusion, no explicit hydrodynamics). The claims that the method “imitates” wave transport at 100-yr timesteps must be framed cautiously: specify what processes are intentionally neglected and where results should not be trusted (e.g., short-term storm driven redistribution). Consider adding a schematic summarising what physical processes are resolved vs parameterised.

We have modified the text to open the description of the transport with the intended scope and assumptions. We emphasize now that the imitation is of the **effects** of the wave tranport, not of the process of wave transport itself. The text list the processes that are not modeled individually. From that text, we hope, it will appear that a schematic summary is difficult to offer, because there is no one-to-one mapping between physical processes and model terms, since the diffusion term in our model represents combined effects of many processes. However, we added in the revision an estimation of the effective diffusion coefficient of sediment in CarboKitten and compared it with estimates of this coefficient from empirical data. Just as diffusion coefficients are difficult to obtain from real-world measurements for timesteps of minutes, parameters of individual physical processes such as wave transport are mutatis mutandis difficult to obtain for timesteps of centuries and we would face the same challenge of assuming time-averaged parameter values for processes that operate at short timescales.

> ### Comment on numerical stability and time stepping
> The transport scheme has CFL / diffusion constraints (Eqs 8 & 9) and the authors note instabilities for some combos (they dropped one run). The manuscript should state clearly the numerical stability limits and their dependency on grid spacing and concentration Cf (with recommended safe Δt relative to Δx for typical parameter ranges).
>
> Also, it is not clear if an automatic runtime checks/warnings exists in the code that compute the recommended number of substeps for transport given current df, Cf and Δx (and halt or warn if unstable).
>
> Other approaches (implicit solver, operator splitting, adaptive substepping, filtering) could be relatively easily implemented to partially circumvent this problem. This could help novice users avoid the non-physical oscillations apparently visible in Figure 9.

In Section 3.3 we present a section dedicated to the CFL limits of the transport model. Because CarboKitten is a forward model that is not completely governed by a single set of PDEs, we are limited to a forward Euler method for the outermost integration scheme, which we argue is diffusive in nature. In our opinion, all forward models should account for this. Because the effective diffusivity can not be predicted a priori (it depends on sediment concentrations in the active layer), all we can do is check the global CFL at run-time. Because this incurs some computational overhead, this functionality is only available when CarboKitten is run in diagnostic mode. We add the following sentence to the end of Section 3.3: "CarboKitten has a diagnostic mode where this condition is checked against, allowing the user to make informed changes to the input parameters. Because the sediment concentration is not known in advance, it is not possible to make this check in advance."

We are not convinced that implementing more advanced approaches like implicit solvers are easily implemented here. Such a solver could be used to integrate the transport equations for a single step. However, within a single model time step, the transport equation is only advective in nature and doesn't suffer scaling issues to the same extent that the global transport has, which is diffusive in nature.

> ### Comments on the Examples section - validation against observations / benchmarks
> In this section of the manuscript, the principal issue is the lack of validation: no comparison with empirical or previously published model results. The manuscript shows internal convergence/benchmark tests (grid size/time step scaling) and example morphologies (atoll, Wheeler diagrams), but it does not validate model output against any empirical carbonate stratigraphic or morphometric dataset (e.g., observed atoll profiles, modern reef platform slope distributions, or published stratigraphic stacking patterns). For a paper presenting a new open-source model intended for hypothesis testing, the lack of empirical or inter-model validation is a substantial gap.
>
> That will be great for instance to insert a section in the example that compare CarboKitten to CarboCAT model as a quantitative validation/benchmark section, possibly reporting RMSE, facies distribution or slope metrics. Would that be feasible?
>
> Similarly, would it be possible to provide a more in-depth sensitivity analysis for key parameters controlling production, lithification, and diffusion. At the moment, Fig. 5 is the only one illustrating this important concept. This will substantially strengthen claims about realism and utility.

We have included an extensive validation case, based on Henglai et al (2024) (https://doi.org/10.1016/j.marpetgeo.2024.106763).

> ### Comments on model parameters definition and choices
> The paper repeatedly notes that many transport/production parameters are poorly constrained and that results are sensitive to them (e.g., diffusivity, lithification half-life, disintegration rate, wave velocities). Table 2 and the text note that values are hard to motivate. But there is only one short sensitivity exploration (Figure 5). In my view, for users to adopt the code, the manuscript should present a clearer sensitivity analysis: which parameters strongly control (i) morphology, (ii) facies patterns, (iii) stability (CFL constraints).
>
> Provide parameter sweeps for the key parameters (diffusivity df, lithification time ct, disintegration rate dr, factory gm and k). Present results as simple summary metrics (e.g., platform width, slope, facies proportions, or some stratigraphic order metric). This will guide users and justify the defaults. To the very least, the authors should add a table 3 or one in the supplement that summarises the different model parameters, their 1/ definition, 2/ default values in the code, 3/ their possible range as well as 4/ their units. It will greatly help adoption of the code by researchers.

We have provided a table with parameters following the requests of the reviewer in an appendix. 

> ### Reproducibility & repository recommendations
> The online documentation (mindthegap-erc.github.io) is great and should be referenced in the manuscript. Also, you should mention the license of the code GPL v3. On a side note, that is not that crucial for the paper, the binder server did not work for me when I tried to run the notebooks… so I installed it locally… might be good to have it fixed.

These are mentioned in the *code-availability* section.

## Line-level revision suggestions
We have applied the suggestions listed below.

> Ln. 40 to 50: regarding models specifically looking at carbonate platform development, the authors might want to add in 1D pyReef-core (https://doi.org/10.5194/gmd-11-2093-2018) and the 2D model from Pastier et al. (https://doi.org/10.1029/2019GC008239). 
> Eq. 3: you are providing the units for the different variables in Table 1 but I would also recommend adding them in text below the eq.
> In Figure 1. What is the value of I0? It needs to be specified.

The value of $I_0 = 400 W/m^2$ is written in the title of the plot. We've added the same information to the figure caption.

> In section 2.3. The reference to Fig. 2 missing. 
> In Fig. 2: missing colour bar to explain the fig. (each colour corresponds to one type of carbonate) 
> Ln. 103: Change Celullar to Cellular 
> Ln. 122: rewrite this sentence: “Every time step the active layer is fed with freshly produced sediment and distintegrated older sediment” and fix distintegrated to disintegrated 
> Ln 123: “After transport a fraction of the entrained sediment is deposited on the sea floor in process that we refer to as lithification, being the process of turning loose sediment into rock”: missing comma after transport; change in process to a process. Also I think you should at least modify the end of this sentence. How about rewriting it as: “Once transported, some of the suspended sediment is deposited on the seafloor, where it becomes incorporated into the substrate through lithification (i.e., the conversion of loose sediment into cohesive rock).” 

With this sentence we want to emphasise our exact use of the term *lithification*, which is here coerced to mean a specific interaction in the model, rather than describing the process itself which should be well familiar to the reader.
 
> Ln 139: I think a formal academic tone will require you to remove all contractions like we’ve, it’s, don’t. So on this line we’ve needs to become we have. There are other instances in the manuscript (e.g., lines 80 and 190 with don’t). 
> Ln. 149: change crosssection to cross-section 
> In Fig. 7, the description of the push and pop amount is difficult to understand and will need some additional information. More specifically, could you explain the relationship between the light blue colours and the size of the parcel (3/4 and 1/2 that you push and pop respectively). 
> Ln 289 change mittigated to mitigated 
> Fig. 4 caption change crosssection to cross-section 
> Fig. 9 caption change crosssection to cross-section 
> Ln. 319: “FIXME ref to the code” replace with something along those lines: “All scripts used to generate figures are available at https://github.com//CarboKitten-paper, release v1.0 (DOI: 10.5281/zenodo.xxxxxxx). The Julia environment is defined by Project.toml and Manifest.toml files.” 
> Ln. 324: Variables external to the production… What do you mean exactly? This is too vague and will need to be reframe. 

We have rephrased it to "Variables external to the model, which modulate the output the most"

> In Fig. 6, you need to add a colour bar for the elevation range. Also in the caption, you need to explain that the superimposed surfaces represent different time step and specify these times. 

The figure is provided to illustate CarboKittens capability to handle different input topologies and their typical use. The elevation levels are also indicated on the z-axis. We refrain from going into too much detail as it would distract from the purpose of the figure. We did add a remark explaining the meaning of the superimposed surface plots.

> In Figs. 9, 10., 11 and 13d,e,f: you will need to add a colour bar like the one in Fig. 4 for the dominant facies. Also, for each simulation include grid size and time steps in the captions to make it easier for the reader. 

# RC 2

We thank the reviewer for constructive answers, which helped us improve the manuscript. Answers to individual comments are listed below.

> General comments

- [x] That said, I was surprised that there was no mention of how this package might fit into the broader context of open-source software for modeling earth surface processes, given how much activity there has been in that space in recent years. For example, to what extent is CarboKitten interoperable with other surface dynamics models, modular model-building packages, and/or data sets? To what extent, if any, does it take advantage of modern interface standards for numerical model codes? Even if the authors feel that these are not relevant issues, it would be useful to present the reasoning behind such a view. 

A note on this has been added in the conclusions part.

> Comments by line or equation number

> 34-5 Is this really the extent of existing forward stratigraphic models? What about SedSim or Dionysus (albeit both closed source I think), MIDAS, Sequence, etc.? 

We changed the text to emphasize that siliciclastic models mentioned are selected examples, because we state that these are not the focus of this article, so a comprehensive list of e.g. fluvial models is not relevant for forward modeling of marine carbonates. DIONISOS is mentioned later in the text, but we added a reference to it in the opening fragment. The Reviewer is right that we made an effort to primarily emphasize Open Source models.

> 80 Lack of subsidence correction was surprising at first. It might help to note that eta is defined relative to a reference level in the bedrock column, rather than to say the geoid or current sea level. 

We added the suggested text. 

> Eq 3: at some point it would be helpful to state how the case w < 0 is handled. The equation itself implies positive exponential growth, which obviously isn't what's intended. 

> 108 It's probably beyond the scope of this paper, but I wonder how this scales with cell size. I suppose larger cells would mean that a given species is effectively competing over a larger territorial area. In any event, the reliance on number of pixels instead of a spatial scale must mean that pixel size is actually a model parameter rather than just a numerical thing. I also wonder whether this could be viewed as a discrete approximation of a continuum formulation. For example, maybe you could view survival and activation as functions of exponentially weighted population density, with a given decay length scale. The cellular algorithm could then be viewed as a discrete approximation of this. But I realize this is kind of a tangential issue for purposes of a model description paper.

We agree that for the CA, pixel size is a model parameter reflecting the area the carbonate factories compete over, and CA behavior is independent of the model's spatial scale. There is a rich body of literature looking at the approximation of continuous spatiotemporal dynamics via CAs, see e.g. @Dormann2001 for an approximation of Turing patterns via CAs with probabilistic transition rules. We have added this reference and a sentence elaborating on this connection. Conversely, there are ways to construct (systems of) PDEs that emulate CAs (e.g., Omohundro, Stephen. "Modelling cellular automata with partial differential equations." Physica D: Nonlinear Phenomena 10.1-2 (1984): 128-134.) However, the resulting CAs are not easily interpretable as biologically meaningful spatial competition.

> 112 I'm not sure what it means for birth priority to be 'rotated every iteration'. 

An explanation has been added.

> Fig 2: what are each of the colors? 

Colors represent facies; we added a sentence to explain.

> 122 please give units or dimensions of Cf 

Units have been added.

> 124 when sediment is deposited/lithified, what facies does it form? Oh never mind, I see the later statement that Cf is considered separately for each facies. So I guess that means there is a PDE for Cf for each f. 

An additional explanation has been added directly in this line.

> 130 This sketch of the algorithm is helpful. It would be even better if you could be a bit more specific in the following sense: if step 2 is he choice of neighbourhood (5 x 5) and activation/viability ranges (6 ≤ n ≤ 10 and 4 ≤ n ≤ 10, respectively). Are these empirical defaults or user-defined parameters? A short sensitivity check or schematic (showing how cell states evolve under different thresholds) would clarify the model’s behaviour.calculating a RATE that will be time-integrated later, then it would be helpful to describe it as a rate; same with Df in step 3. In step 4, perhaps refer to flux rather than concentration? In step 5, to be consistent with the others, you could give the rate (or thickness?) variable. Also, if the time integration of steps 2-5 is done all at once, then it would be helpful to add a step in which the integration is performed and w, eta, and Cf are updated. 

We appreciate that this has not been clear enough in the original manuscript. We have added a brief explanation in the revision, as well as expanded the documentation of CarboKitten online, so that the algorithm description is presented together with the code.

> 144 typo 

Corrected.

> Eq 5: Here and in the following development it would be very helpful to clarify units or dimensions. From equations 5 and 6, qf must have units of velocity times whatever units Cf has.

> 163 calling df a diffusivity suggests that it should have dimensions of length squared per time, but if vf is a velocity, then shouldn't df also have dimensions of velocity? I am wondering whether there isn't a 'hidden' length scale, such as active layer thickness. If for example you defined active layer thickness as h, Cf as dimensionless volumetric concentration, and qf as

> qf = -Cf h (df grad(eta) + vf)

> then the product h df would be a proper diffusivity, and qf would be either a volume or mass flux per unit width (depending on whether concentration is vol/vol or mass/vol). And multiplying vf by active layer thickness and concentration would make it a proper flux per unit width. In any case, some explanation in the text would help readers make sense of these variables. 

Following this feedback we renamed diffusivity to transfport_coefficient in the software, documentation and the manuscript. Hopefully this will prevent ambiguity.
The active layer thickness does not enter into the equations, just the amount of sediment that is entrained in the active layer.

> 167 typo 

Corrected.

> *Moderate* Add appendix with derivation of Eq 7. 

>  Eq 7: I tried re-deriving this but failed. I recommend providing a derivation in an appendix or supplement. Probably I'm just being daft, but for what it's worth, here is the source of my reasoning; hopefully the authors can show that I have made a basic mistake in the following:
>  
> The right side of (6) has div(q) (I am leaving off the f subscripts, and using capital D for derivatives).
>  
>  -dC/dt = D(q)
>  = D(C d D(eta) + C v)
>  = D(C d D(eta)) + D(C v)
>  Assume d != f(x,y)
>  = d D(C D(eta)) + D(C v)
> 
>  Apply the product rule to both terms:
>  
>  = d C D^2(eta)
>  + d D(eta) D(C)
>  + C D(v)
>  + v D(C)
>  The equivalents in (7), if you factor out the -1, are:
>  d C D^2(w)
>  + d D(w) D(C)
>  - s C D(w)
>  + v D(C)
>  
>  As I say, I am doing this quickly and there is a good chance I have made a mistake in the above, but it would be helpful to include (either in main text, appendix, or supplement) material that clarifies:
>
>  - the origin of s(w) (which is described as a derivative with respect to water depth, but presumably the divergence operator in 6 is with respect to horizontal coordinates given that eta and w are both functions of (x,y,t) and not vertical coordinate z, so it is not clear where this comes from.)
>
>  - the signs of the terms (my quick derivation suggests there may be a sign error; for example the diffusion term should be positive when written in terms of eta, and it should therefore become negative when w is substituted)
>
>  - how you end up with 3 terms with derivatives of w when the form of 5 and 6 suggest there should only be two.

We provide an appendix with a complete derivation. The three terms appear as follows: one by chain-rule on the velocity profile, and two by product rule on d C D(w). There was a mistake with a minus sign in the sediment flux definition. Note that CarboKitten has unit tests to make sure that no such mistakes are present in the code.

> 173 not clear to me how/why Cf acts as a proxy for eta 

We added an explanation how the cycle of disintegration, transport and lithification links topography and sediment concentration such that, to a first order D(C, t) ~ D(eta, t).

> 194-5 please show the form of this slope function 

We interpret this request as a likely result of ambiguous phrasing in our manuscript. By "In this study an exponential slope function was assumed" refers to Bosscher & Southam (1992), not CarboKitten, and is based on empirical observations, as mentioned in the text. CarboKitten's algorithm does not require assumptions on slope shapes, the shapes emerge from the transport mechanism. We have corrected the phrasing to remove the ambiguity.

> - [x] 208 it would be helpful to remind readers of the variables for disintegration rate coefficient and lithification time parameter.
> Also, the comment about scaling suggests that presenting either a non dimensional form of the governing equations, or at least of the parameters, could be useful. Presumably something involving the ratio of lithification time and disintegration rate would pop out. Worth considering at least. 

Added a section explaining the relation of lithification time and disintegration rate in the form of an equilibrium sediment amount in the active layer. In absence of production we get an equilibrium sediment concentration of <C> = r l / sqrt(2), where r is the disintegration rate and l the lithification time. Taking our transport coefficient we can then derive an effective diffusivity d <C>.

> - [x] 226 is the upwind advection scheme first or second order, and if second order, linear or nonlinear? 

Added word first-order.

> - [x] 232 nice to have the two time-step limiters presented, thank you
> - [x] 234 typo

line was removed in edit.

> - [x] 249 not clear to me what 'no longer an active component' means. Does it imply that if erosion were to eat into previous deposits that the original facies composition of those deposits would be ignored? 

Removed this by-sentence as it is indeed confusing. We somehow want to emphasise that the buffer is only used for precisely the purpose of retaining facies composition in the face of erosion.

> - [x] 253-7 it sounds as if the height of each element is constant; if correct, it would be worth saying so explicitly (I have seen other treatments, for example where layers are based on time rather than thickness). 

added a paragraph explaining our reasoning here.

> - [x] 302-305 nice touch to show a convergence test.
> - [x] 313 Wonderful to see the literature programming method used here.
