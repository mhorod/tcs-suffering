#!/bin/bash
export TEXINPUTS="$(readlink -f common):$TEXINPUTS"

cd ${1}
# Execute command twice to generate table of contents
pdflatex -interaction=nonstopmode -file-line-error --output-directory=../build main.tex
pdflatex -interaction=nonstopmode -file-line-error --output-directory=../build main.tex

