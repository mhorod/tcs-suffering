#!/bin/bash
export TEXINPUTS="$(readlink -f common):$TEXINPUTS"

mkdir build/${1}
cd ${1}
# Execute command twice to generate table of contents
pdflatex -interaction=nonstopmode -file-line-error -shell-escape --output-directory=../build/${1} main.tex
pdflatex -interaction=nonstopmode -file-line-error -shell-escape --output-directory=../build/${1} main.tex

