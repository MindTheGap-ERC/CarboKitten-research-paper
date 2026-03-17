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

> *Moderate* Add appendix with derivation of Eq 7. @jhidding

>  Eq 7: I tried re-deriving this but failed. I recommend providing a derivation in an appendix or supplement. Probably I'm just being daft, but for what it's worth, here is the source of my reasoning; hopefully the authors can show that I have made a basic mistake in the following:
  
> The right side of (6) has div(q) (I am leaving off the f subscripts, and using capital D for derivatives).
  
>  -dC/dt = D(q)
>  = D(C d D(eta) + C v)
>  = D(C d D(eta)) + D(C v)
>  Assume d != f(x,y)
>  = d D(C D(eta)) + D(C v)
  
  
  
>  Apply the product rule to both terms:
  
>  = d C D^2(eta)
>  + d D(eta) D(C)
>  + C D(v)
>  + v D(C)
>  The equivalents in (7), if you factor out the -1, are:
>  d C D^2(w)
>  + d D(w) D(C)
>  - s C D(w)
>  + v D(C)
  
>  As I say, I am doing this quickly and there is a good chance I have made a mistake in the above, but it would be helpful to include (either in main text, appendix, or supplement) material that clarifies:

>  - the origin of s(w) (which is described as a derivative with respect to water depth, but presumably the divergence operator in 6 is with respect to horizontal coordinates given that eta and w are both functions of (x,y,t) and not vertical coordinate z, so it is not clear where this comes from.)

>  - the signs of the terms (my quick derivation suggests there may be a sign error; for example the diffusion term should be positive when written in terms of eta, and it should therefore become negative when w is substituted)

>  - how you end up with 3 terms with derivatives of w when the form of 5 and 6 suggest there should only be two.

We provide an appendix with a complete derivation.

> 173 not clear to me how/why Cf acts as a proxy for eta 

> 194-5 please show the form of this slope function 

We interpret this request as a likely result of ambiguous phrasing in our manuscript. By "In this study an exponential slope function was assumed" refers to Bosscher & Southam (1992), not CarboKitten, and is based on empirical observations, as mentioned in the text. CarboKitten's algorithm does not require assumptions on slope shapes, the shapes emerge from the transport mechanism. We have corrected the phrasing to remove the ambiguity.

- [x] 208 it would be helpful to remind readers of the variables for disintegration rate coefficient and lithification time parameter.

  Also, the comment about scaling suggests that presenting either a non dimensional form of the governing equations, or at least of the parameters, could be useful. Presumably something involving the ratio of lithification time and disintegration rate would pop out. Worth considering at least. @jhidding

> Added a section explaining the relation of lithification time and disintegration rate in the form of an equilibrium sediment amount in the active layer.

- [x] 226 is the upwind advection scheme first or second order, and if second order, linear or nonlinear? @jhidding

> Added word first-order.

- [x] 232 nice to have the two time-step limiters presented, thank you

- [x] 234 typo

> line was removed in edit.

- [ ] 249 not clear to me what 'no longer an active component' means. Does it imply that if erosion were to eat into previous deposits that the original facies composition of those deposits would be ignored? @jhidding

> Removed this by-sentence as it is indeed confusing. We somehow want to emphasise that the buffer is only used for precisely the purpose of retaining facies composition in the face of erosion.

- [x] 253-7 it sounds as if the height of each element is constant; if correct, it would be worth saying so explicitly (I have seen other treatments, for example where layers are based on time rather than thickness). @jhidding

> added a paragraph explaining our reasoning here.

- [x] 302-305 nice touch to show a convergence test.

- [x] 313 Wonderful to see the literature programming method used here.

Citation: https://doi.org/10.5194/egusphere-2025-4561-RC2
