.PHONY: all

pandoc_args +=
pandoc_latex_args += -s -t latex

all: build/paper.pdf

build/paper.tex: md/paper.md
	@echo "Running pandoc"
	@mkdir -p $(@D)
	@pandoc $(pandoc_args) $(pandoc_latex_args) -o $@ $^
 
build/paper.pdf: build/paper.tex latex/latexmkrc
	@echo "Running LaTeX"
	@cd build; latexmk -r ../latex/latexmkrc
		
clean:
	@echo "Cleaning build directory"
	@rm -rf build

