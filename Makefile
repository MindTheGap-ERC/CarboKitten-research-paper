.PHONY: all debug
 
pandoc_args += --citeproc --bibliography md/ref.bib
pandoc_args += --lua-filter pandoc/hide.lua
pandoc_latex_args += -s -t latex -H latex/preamble.tex
figures_md = $(wildcard md/fig/*)
figures = $(figures_md:md/%=build/%)

all: build/paper.pdf

debug: md/paper.md
	@pandoc $(pandoc_args) -s -t native $<

build/paper.tex: md/paper.md
	@echo "Running pandoc"
	@mkdir -p $(@D)
	@pandoc $(pandoc_args) $(pandoc_latex_args) -o $@ $^
 
build/paper.pdf: build/paper.tex latex/latexmkrc $(figures)
	@echo "Running LaTeX"
	@cd build; latexmk -r ../latex/latexmkrc

build/fig/%: md/fig/%
	@echo "Copying figure $@"
	@mkdir -p $(@D)
	@cp $< $@

clean:
	@echo "Cleaning build directory"
	@rm -rf build

