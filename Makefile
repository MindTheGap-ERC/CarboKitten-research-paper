.PHONY: all debug clean daemon manuscript copy-figures flowchart

pandoc_args += -fmarkdown+latex_macros
pandoc_args += --lua-filter pandoc/hide.lua
pandoc_args += --lua-filter pandoc/special-divs.lua
pandoc_args += --lua-filter pandoc/eqnos.lua
pandoc_args += --lua-filter pandoc/fignos.lua
pandoc_args += --lua-filter pandoc/figref.lua
pandoc_args += --lua-filter pandoc/wide_tables.lua
pandoc_args += --lua-filter pandoc/plain_tables.lua
pandoc_args += --lua-filter pandoc/wide_figures.lua
pandoc_args += --lua-filter pandoc/special-headers.lua
pandoc_args += --natbib
# pandoc_args += --citeproc --bibliography md/ref.bib
pandoc_latex_args += -s --template latex/template.tex -t latex
# pandoc_args += -H latex/preamble.tex
figures_md = $(wildcard md/fig/*)
figures = $(figures_md:md/%=build/%)

all: build/paper.pdf

manuscript: build/manuscript.pdf build/manuscript.diff.pdf

debug: md/paper.md
	@pandoc $(pandoc_args) -s -t native $<

copy-figures: $(figures)

build/paper.tex: md/paper.md
	@echo "Running pandoc"
	@mkdir -p $(@D)
	@pandoc $(pandoc_args) $(pandoc_latex_args) -o $@ $^

build/manuscript.tex: md/paper.md
	@echo "Running pandoc"
	@mkdir -p $(@D)
	@pandoc $(pandoc_args) -V manuscript $(pandoc_latex_args) -o $@ $^

build/ref.bib: md/ref.bib
	@echo "Copying ref.bib"
	@mkdir -p $(@D)
	@cp $< $@

build/copernicus.bst: latex/copernicus/copernicus.bst
	@echo "Copying copernicus.bst"
	@mkdir -p $(@D)
	@cp $< $@

build/paper.pdf: build/paper.tex build/ref.bib build/copernicus.bst latex/latexmkrc $(figures)
	@echo "Running LaTeX"
	@cd build; latexmk -r ../latex/latexmkrc paper.tex

build/manuscript.pdf build/manuscript.bbl: build/manuscript.tex build/ref.bib build/copernicus.bst latex/latexmkrc $(figures)
	@echo "Running LaTeX"
	@cd build; latexmk -r ../latex/latexmkrc manuscript.tex

build/fig/%: md/fig/%
	@echo "Copying figure $@"
	@mkdir -p $(@D)
	@cp $< $@

clean:
	@echo "Cleaning build directory"
	@rm -rf build

daemon:
	@julia --project=. -t 4 --startup-file=no -e 'using DaemonMode; serve()'

flowchart: md/fig/flowchart.pdf

md/fig/flowchart.pdf: md/flowchart.scm md/flowchart.css
	@echo "Rendering flow chart"
	@guile --r6rs tools/xml-gen/xml-gen.scm < md/flowchart.scm 2> /dev/null | rsvg-convert -f pdf1.5 -o $@

# LaTeX diff

build/paper.rc1.md:
	git show rc1:md/paper.md > $@

build/manuscript.rc1.tex: build/paper.rc1.md
	@echo "Running pandoc"
	@mkdir -p $(@D)
	@pandoc $(pandoc_args) -V manuscript $(pandoc_latex_args) -o $@ $^

build/manuscript.diff.tex: build/manuscript.rc1.tex build/manuscript.tex
	latexdiff $^ | sed -e 's/renewcommand.*equation.*//' > $@

build/manuscript.rc1.bbl: build/manuscript.rc1.tex
	pdflatex $<

build/manuscript.diff.bbl: build/manuscript.rc1.bbl build/manuscript.bbl
	latexdiff $^ > $@

build/manuscript.diff.pdf: build/manuscript.diff.tex
	@echo "Running LaTeX"
	@cd build; latexmk -r ../latex/latexmkrc -pdflatex='pdflatex -interaction nonstopmode' manuscript.diff.tex
