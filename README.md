# CarboKitten-research-paper
A paper describing CarboKitten

The source files for the paper should be placed in `md/`, that is `md/paper.md` figures in `md/fig`, and references in `md/ref.bib`. The paper is written in Markdown, that is then compiled down to LaTeX and PDF using Pandoc. Any source files for the LaTeX (`cls` files for the Journal template mostly) should be placed in `latex/`, while Pandoc filters are placed in `pandoc/`.

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
dnf install texlive-scheme-medium latexmk
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
