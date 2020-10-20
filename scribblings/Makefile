SCRBL := scribble ++main-xref-in --redirect-main http://docs.racket-lang.org/

PDF = $(patsubst %.scrbl, %.pdf, $(shell ls *.scrbl))
HTML = $(patsubst %.scrbl, %.html, $(shell ls *.scrbl))
%.pdf: %.scrbl
	@$(SCRBL) ++style texstyle.tex --latex $<
	@xelatex $(patsubst %.pdf, %.tex, $@)
%.html: %.scrbl
	@$(SCRBL) $<

.PHONY: pdf
pdf: $(PDF)
.PHONY: html
html: $(HTML)

.PHONY: clean
clean:
	@rm *.css *.js *.html
