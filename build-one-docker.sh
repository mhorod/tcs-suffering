#!/bin/bash
TEXINPUTS="/data/common:$TEXINPUTS"
CMD="pdflatex -interaction=nonstopmode -file-line-error --output-directory=../build main.tex"
./latexdockercmd.sh /bin/bash -c "export TEXINPUTS=\"${TEXINPUTS}\"; cd ${1}; ${CMD}; ${CMD}"

