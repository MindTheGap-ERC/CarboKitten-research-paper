# CarboKitten-research-paper
A paper describing CarboKitten

The source files for the paper should be placed in `md/`, that is `md/paper.md` figures in `md/fig`, and references in `md/ref.bib`. The paper is written in Markdown, that is then compiled down to LaTeX and PDF using Pandoc. Any source files for the LaTeX (`cls` files for the Journal template mostly) should be placed in `latex/`, while Pandoc filters are placed in `pandoc/`.

Figures should be located in `md/fig` so that the Markdown renders reasonably well on Github.

Figures and example code should be evaluated by Julia, so there should be a `Project.toml`, `Manifest.toml` and `src/jl/*.jl` for scripts.

Code fragments in the paper should be evaluating to the given output. Something that should be enforced by using Entangled.

All figures should have source files available. If they were created in``` Inkscape, the SVG file is considered 'source' and placed in `src/svg`.

When the paper is published, a release of the package should be made and artifacts uploaded to Zenodo.

All actions should be available from a `Makefile`, even if we use `brei` to build figures from Entangled sources, and `latexmk` to build the eventual LaTeX. All generated output should appear in `build/`.

## Prerequisites

### Julia

Julia dependencies:
- `CarboKitten` what else to talk about
- `CairoMakie` for high quality plotting
- `GraphvizDotLang` for drawing graphs

### Pandoc

Use Pandoc &ge; 3.1, compiled with Lua support. On Fedora:

```bash
dnf install pandoc
```

### LaTeX

Use TeXLive &ge; 2023, building with LuaTeX and `latexmk`. On Fedora:

```bash
dnf install texlive-scheme-medium latexmk texlive-selnolig texlive-svg
```

### Entangled

```bash
pip install entangled-cli
```

### GNU Make

Used to combine everything.

## Markdown

Since we're using Pandoc, we can keep our Markdown clean. Any particular items can be given a CSS class or ID and then translated to LaTeX using a Pandoc filter.

A `div` (being a custom content block) can be marked as follows:

~~~markdown
:::abstract
...
:::
~~~

In this example, we speak of an `abstract`-div, that is then translated to

```latex
\begin{abstract}
...
\end{abstract}
```

A similar thing can be done with `span`s.

~~~markdown
[johnny@mail.edu]{.author-email}
~~~

See the [Pandoc documentation](https://pandoc.org/chunkedhtml-demo/8.18-divs-and-spans.html).

Citations follow a syntax like `@Bosscher1992`, where `Bosscher1992` is an entry in the `md/ref.bib`. There are other forms for citation translating to `\citet` or `\citep` in LaTeX, see [Pandoc documentation](https://pandoc.org/chunkedhtml-demo/8.20-citation-syntax.html).

### Filters

- `hide.lua` hides blocks that are marked with `:::hide`. This is used to hide code blocks.

- `fignos.lua` and `figref.lua` number the figures and enable referencing those figures in the text. The label should be given at the end of the caption, which should be given as a paragraph following the image, starting with `Figure: `. Example:

```md
An example of this profile is shown in Figure @fig:wave-transport-magnitude.

![Depth profile](fig/wave-transport-magnitude.svg){width=100%}

Figure: Depth profile of velocity and shear. The velocity profile was taylored to have a maximum of $10 \textrm{m}/\textrm{yr}$ at a depth of $20 \textrm{m}$. Where the shear is non-zero, there is a net accumulation of sediment. {#fig:wave-transport-magnitude}
```

- `eqnos.lua` numbers equation and handles references to equations.

## Debugging output

To debug the conversion from Markdown to LaTeX it is sometimes useful to look at Pandoc's abstract syntax tree directly. Pandoc can show this when using `-t native`. This can also run with `make debug`.

