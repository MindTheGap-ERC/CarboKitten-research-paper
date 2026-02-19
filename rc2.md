## General comments

First of all, bravo to the authors for building a comprehensive open-source carbonate stratigraphic model. This is a much needed contribution, and one that nicely builds on the previous CarboCAT model written in Matlab by Burgess and colleagues. The manuscript does a good job of presenting the theory and capabilities of the new model. I appreciate the user-friendly nature of the design, including examples, I/O, visualisation tools, and a literate programming approach that blends code and documentation.

That said, I was surprised that there was no mention of how this package might fit into the broader context of open-source software for modeling earth surface processes, given how much activity there has been in that space in recent years. For example, to what extent is CarboKitten interoperable with other surface dynamics models, modular model-building packages, and/or data sets? To what extent, if any, does it take advantage of modern interface standards for numerical model codes? Even if the authors feel that these are not relevant issues, it would be useful to present the reasoning behind such a view.

Overall, the manuscript is well written and illustrated. There are some aspects of the mathematics, detailed below, that could benefit from more detailed presentation. But on the whole I feel this is a very nice contribution. I especially appreciate the authors' forthrightness in pointing out, for example, the limitations of free parameters. I recommend publication after minor revisions.

## Comments by line or equation number

- [ ] 34-5 Is this really the extent of existing forward stratigraphic models? What about SedSim or Dionysus (albeit both closed source I think), MIDAS, Sequence, etc.? @emiliajarochowska

- [ ] 80 Lack of subsidence correction was surprising at first. It might help to note that eta is defined relative to a reference level in the bedrock column, rather than to say the geoid or current sea level. @jhidding

- [ ] Eq 3: at some point it would be helpful to state how the case w < 0 is handled. The equation itself implies positive exponential growth, which obviously isn't what's intended. @jhidding

- [ ] 108 It's probably beyond the scope of this paper, but I wonder how this scales with cell size. I suppose larger cells would mean that a given species is effectively competing over a larger territorial area. In any event, the reliance on number of pixels instead of a spatial scale must mean that pixel size is actually a model parameter rather than just a numerical thing. I also wonder whether this could be viewed as a discrete approximation of a continuum formulation. For example, maybe you could view survival and activation as functions of exponentially weighted population density, with a given decay length scale. The cellular algorithm could then be viewed as a discrete approximation of this. But I realize this is kind of a tangential issue for purposes of a model description paper. @jhidding

- [ ] 112 I'm not sure what it means for birth priority to be 'rotated every iteration'. @jhidding

- [ ] Fig 2: what are each of the colors? @jhidding

- [ ] 122 please give units or dimensions of Cf @jhidding

- [ ] 124 when sediment is deposited/lithified, what facies does it form? Oh never mind, I see the later statement that Cf is considered separately for each facies. So I guess that means there is a PDE for Cf for each f. @jhidding

- [ ] 130 This sketch of the algorithm is helpful. It would be even better if you could be a bit more specific in the following sense: if step 2 is calculating a RATE that will be time-integrated later, then it would be helpful to describe it as a rate; same with Df in step 3. In step 4, perhaps refer to flux rather than concentration? In step 5, to be consistent with the others, you could give the rate (or thickness?) variable. Also, if the time integration of steps 2-5 is done all at once, then it would be helpful to add a step in which the integration is performed and w, eta, and Cf are updated. @jhidding

- [ ] 144 typo @jhidding

- [ ] Eq 5: Here and in the following development it would be very helpful to clarify units or dimensions. From equations 5 and 6, qf must have units of velocity times whatever units Cf has. @jhidding

- [ ] 163 calling df a diffusivity suggests that it should have dimensions of length squared per time, but if vf is a velocity, then shouldn't df also have dimensions of velocity? I am wondering whether there isn't a 'hidden' length scale, such as active layer thickness. If for example you defined active layer thickness as h, Cf as dimensionless volumetric concentration, and qf as

qf = -Cf h (df grad(eta) + vf)

then the product h df would be a proper diffusivity, and qf would be either a volume or mass flux per unit width (depending on whether concentration is vol/vol or mass/vol). And multiplying vf by active layer thickness and concentration would make it a proper flux per unit width. In any case, some explanation in the text would help readers make sense of these variables. @jhidding

- [ ] 167 typo @jhidding

- [ ] *Moderate* Add appendix with derivation of Eq 7. @jhidding

  Eq 7: I tried re-deriving this but failed. I recommend providing a derivation in an appendix or supplement. Probably I'm just being daft, but for what it's worth, here is the source of my reasoning; hopefully the authors can show that I have made a basic mistake in the following:
  
  The right side of (6) has div(q) (I am leaving off the f subscripts, and using capital D for derivatives).
  
  -dC/dt = D(q)
  
  = D(C d D(eta) + C v)
  
  = D(C d D(eta)) + D(C v)
  
  Assume d != f(x,y)
  
  = d D(C D(eta)) + D(C v)
  
  
  
  Apply the product rule to both terms:
  
  = d C D^2(eta)
  
  + d D(eta) D(C)
  
  + C D(v)
  
  + v D(C)
  
  The equivalents in (7), if you factor out the -1, are:
  
  d C D^2(w)
  
  + d D(w) D(C)
  
  - s C D(w)
  
  + v D(C)
  
  
  
  As I say, I am doing this quickly and there is a good chance I have made a mistake in the above, but it would be helpful to include (either in main text, appendix, or supplement) material that clarifies:

  - the origin of s(w) (which is described as a derivative with respect to water depth, but presumably the divergence operator in 6 is with respect to horizontal coordinates given that eta and w are both functions of (x,y,t) and not vertical coordinate z, so it is not clear where this comes from.)

  - the signs of the terms (my quick derivation suggests there may be a sign error; for example the diffusion term should be positive when written in terms of eta, and it should therefore become negative when w is substituted)

  - how you end up with 3 terms with derivatives of w when the form of 5 and 6 suggest there should only be two.

- [ ] 173 not clear to me how/why Cf acts as a proxy for eta @jhidding

- [ ] 194-5 please show the form of this slope function @jhidding

- [ ] 205-6 I appreciate the honesty of this statement!

- [ ] 208 it would be helpful to remind readers of the variables for disintegration rate coefficient and lithification time parameter.

  Also, the comment about scaling suggests that presenting either a non dimensional form of the governing equations, or at least of the parameters, could be useful. Presumably something involving the ratio of lithification time and disintegration rate would pop out. Worth considering at least.

- [ ] 226 is the upwind advection scheme first or second order, and if second order, linear or nonlinear?

- [ ] 232 nice to have the two time-step limiters presented, thank you

- [ ] 234 typo

- [ ] 249 not clear to me what 'no longer an active component' means. Does it imply that if erosion were to eat into previous deposits that the original facies composition of those deposits would be ignored?

- [ ] 253-7 it sounds as if the height of each element is constant; if correct, it would be worth saying so explicitly (I have seen other treatments, for example where layers are based on time rather than thickness).

- [ ] 302-305 nice touch to show a convergence test.

- [ ] 313 Wonderful to see the literature programming method used here.

Citation: https://doi.org/10.5194/egusphere-2025-4561-RC2 
