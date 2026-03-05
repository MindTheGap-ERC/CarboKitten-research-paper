## Summary

The manuscript presents CarboKitten, an open-source stratigraphic forward model for carbonate platforms implemented in Julia. The model combines (1) a Bosscher & Schlager (1992) style carbonate production module with three “factories” (euphotic / oligophotic / aphotic), (2) a cellular automaton to generate biologically-driven spatial facies heterogeneity following Burgess (2013), and (3) a finite-difference, active-layer transport scheme inspired by Paola et al. (1992). The software emphasises accessibility, HDF5 outputs, visualization utilities, and performance; several examples (sea-level forcing, insolation, wave-transport atoll) and scalability/benchmarking are presented. I believe the model is elegant, open-source, and clearly documented, representing an important contribution to the carbonate-modelling community.

## Recommendation

I recommend several revisions/improvements before publication. Overall, the manuscript is well written, and the software fills a clear niche (open, Julia, carbonate-focused, CA + transport). However, the paper currently lacks adequate empirical/quantitative validation and some methodological details and justifications that are necessary for an EGU-Esurf research/software paper (see comments below). Many of the issues are fixable with additional analyses, clarifications and small code/documentation updates.

The principal issues are

1. insufficient validation -- no comparison with empirical or previously published model results;
2. lack of a systematic sensitivity analysis for key parameters controlling production, lithification, and diffusion;
3. incomplete discussion of numerical stability (CFL limits, time step guidance) and missing automatic checks; and
4. incomplete reproducibility: figure-generation scripts and environment files are not yet linked (there is still a “FIXME” placeholder).

Once these items are addressed, together with minor editorial corrections (typos, units in tables, full code citation, consistent references), the paper will be suitable for publication. There is a really good online documentation associated with the code and I believe it has strong pedagogical potential and could become a reference implementation for open carbonate platform forward models.

## General comments

> These comments are converted into issues already. - JH

 1. Comment on CA

The description of the CA in Sect. 2.3 provides a quick overview of how ecological succession is emulated, but several aspects would benefit from clarification. First, the implementation is said to be a “direct reimplementation of Burgess (2013) CarboCAT,” yet no details are given about whether any modifications were introduced or tested (e.g., neighbourhood size, rule thresholds, asynchronous vs synchronous updating). It would be helpful to state explicitly whether the algorithm reproduces Burgess’s rules verbatim or if adjustments were made for computational or ecological reasons.

In addition, please justify the choice of neighbourhood (5 x 5) and activation/viability ranges (6 ≤ n ≤ 10 and 4 ≤ n ≤ 10, respectively). Are these empirical defaults or user-defined parameters? A short sensitivity check or schematic (showing how cell states evolve under different thresholds) would clarify the model’s behaviour.

Finally, consider clarifying how birth priority rotation among factories is implemented (e.g., cyclic randomisation vs deterministic shift) and how this influences facies patterns or convergence. These details would improve transparency and reproducibility of the CA module.

2. Comment on sediment buffer depth

The manuscript clearly explains the logic and purpose of the sediment buffer (Sect. 4.2) but does not specify how the depth dimension; that is, the number of vertical layers retained in memory; is determined. It would be helpful to indicate whether this is a user-defined parameter, a fixed default value, or adaptive. Providing the typical range used in the examples (e.g., number of layers or equivalent physical thickness) would clarify the model’s temporal and vertical “memory” for sediment composition and its impact on reworking behaviour. I recommend adding this information to the methods description in Section 4.2. The authors describe the buffer as a stack, and I presume it operates under a First-In-First-Out (FIFO) data structure.

3. Comment on the transport model physical justification and limitations

The active-layer finite difference transport is novel for carbonates here; the authors should more explicitly discuss the assumptions and limits (e.g., treatment of grain size, cohesive vs. non-cohesive sediments, role of storms vs background transport, lateral advection vs slope diffusion, no explicit hydrodynamics). The claims that the method “imitates” wave transport at 100-yr timesteps must be framed cautiously: specify what processes are intentionally neglected and where results should not be trusted (e.g., short-term storm driven redistribution). Consider adding a schematic summarising what physical processes are resolved vs parameterised.

4. Comment on numerical stability and time stepping

The transport scheme has CFL / diffusion constraints (Eqs 8 & 9) and the authors note instabilities for some combos (they dropped one run). The manuscript should state clearly the numerical stability limits and their dependency on grid spacing and concentration Cf (with recommended safe Δt relative to Δx for typical parameter ranges).

Also, it is not clear if an automatic runtime checks/warnings exists in the code that compute the recommended number of substeps for transport given current df, Cf and Δx (and halt or warn if unstable).

Other approaches (implicit solver, operator splitting, adaptive substepping, filtering) could be relatively easily implemented to partially circumvent this problem. This could help novice users avoid the non-physical oscillations apparently visible in Figure 9.

5. Comments on the Examples section - validation against observations / benchmarks

In this section of the manuscript, the principal issue is the lack of validation: no comparison with empirical or previously published model results. The manuscript shows internal convergence/benchmark tests (grid size/time step scaling) and example morphologies (atoll, Wheeler diagrams), but it does not validate model output against any empirical carbonate stratigraphic or morphometric dataset (e.g., observed atoll profiles, modern reef platform slope distributions, or published stratigraphic stacking patterns). For a paper presenting a new open-source model intended for hypothesis testing, the lack of empirical or inter-model validation is a substantial gap.

That will be great for instance to insert a section in the example that compare CarboKitten to CarboCAT model as a quantitative validation/benchmark section, possibly reporting RMSE, facies distribution or slope metrics. Would that be feasible?

Similarly, would it be possible to provide a more in-depth sensitivity analysis for key parameters controlling production, lithification, and diffusion. At the moment, Fig. 5 is the only one illustrating this important concept. This will substantially strengthen claims about realism and utility.

6. Comments on model parameters definition and choices

The paper repeatedly notes that many transport/production parameters are poorly constrained and that results are sensitive to them (e.g., diffusivity, lithification half-life, disintegration rate, wave velocities). Table 2 and the text note that values are hard to motivate. But there is only one short sensitivity exploration (Figure 5). In my view, for users to adopt the code, the manuscript should present a clearer sensitivity analysis: which parameters strongly control (i) morphology, (ii) facies patterns, (iii) stability (CFL constraints).

Provide parameter sweeps for the key parameters (diffusivity df, lithification time ct, disintegration rate dr, factory gm and k). Present results as simple summary metrics (e.g., platform width, slope, facies proportions, or some stratigraphic order metric). This will guide users and justify the defaults. To the very least, the authors should add a table 3 or one in the supplement that summarises the different model parameters, their 1/ definition, 2/ default values in the code, 3/ their possible range as well as 4/ their units. It will greatly help adoption of the code by researchers.

> We have provided a table with parameters following the requests of the reviewe in an appendix. 


7. Reproducibility & repository recommendations

The online documentation (mindthegap-erc.github.io) is great and should be referenced in the manuscript. Also, you should mention the license of the code GPL v3. On a side note, that is not that crucial for the paper, the binder server did not work for me when I tried to run the notebooks… so I installed it locally… might be good to have it fixed.

## Line-level revision suggestions

- [ ] Ln. 40 to 50: regarding models specifically looking at carbonate platform development, the authors might want to add in 1D pyReef-core (https://doi.org/10.5194/gmd-11-2093-2018) and the 2D model from Pastier et al. (https://doi.org/10.1029/2019GC008239). @emiliajarochowska

- [ ] Eq. 3: you are providing the units for the different variables in Table 1 but I would also recommend adding them in text below the eq. @jhidding

- [ ] In Figure 1. What is the value of I0? It needs to be specified. @jhidding

- [ ] In section 2.3. The reference to Fig. 2 missing. @jhidding

- [ ] In Fig. 2: missing colour bar to explain the fig. (each colour corresponds to one type of carbonate) @jhidding

- [ ] Ln. 103: Change Celullar to Cellular @jhidding

- [ ] Ln. 122: rewrite this sentence: “Every time step the active layer is fed with freshly produced sediment and distintegrated older sediment” and fix distintegrated to disintegrated @jhidding

- [ ] Ln 123: “After transport a fraction of the entrained sediment is deposited on the sea floor in process that we refer to as lithification, being the process of turning loose sediment into rock”: missing comma after transport; change in process to a process. Also I think you should at least modify the end of this sentence. How about rewriting it as: “Once transported, some of the suspended sediment is deposited on the seafloor, where it becomes incorporated into the substrate through lithification (i.e., the conversion of loose sediment into cohesive rock).” @jhidding

- [ ] Ln 139: I think a formal academic tone will require you to remove all contractions like we’ve, it’s, don’t. So on this line we’ve needs to become we have. There are other instances in the manuscript (e.g., lines 80 and 190 with don’t). @jhidding

- [ ] Ln. 149: change crosssection to cross-section @jhidding

- [ ] In Fig. 7, the description of the push and pop amount is difficult to understand and will need some additional information. More specifically, could you explain the relationship between the light blue colours and the size of the parcel (3/4 and 1/2 that you push and pop respectively). @jhidding

- [ ] Ln 289 change mittigated to mitigated @jhidding

- [ ] Fig. 4 caption change crosssection to cross-section @jhidding

- [ ] Fig. 9 caption change crosssection to cross-section @jhidding

- [ ] Ln. 319: “FIXME ref to the code” replace with something along those lines: “All scripts used to generate figures are available at https://github.com//CarboKitten-paper, release v1.0 (DOI: 10.5281/zenodo.xxxxxxx). The Julia environment is defined by Project.toml and Manifest.toml files.” @jhidding

- [ ] Ln. 324: Variables external to the production… What do you mean exactly? This is too vague and will need to be reframe. 

> We have rephrased it to "Variables external to the model, which modulate the output the most"

- [ ] In Fig. 6, you need to add a colour bar for the elevation range. Also in the caption, you need to explain that the superimposed surfaces represent different time step and specify these times. @jhidding

- [ ] In Figs. 9, 10., 11 and 13d,e,f: you will need to add a colour bar like the one in Fig. 4 for the dominant facies. Also, for each simulation include grid size and time steps in the captions to make it easier for the reader. @jhidding

Citation: https://doi.org/10.5194/egusphere-2025-4561-RC1
