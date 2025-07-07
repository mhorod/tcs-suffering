#!/bin/bash
mkdir build/${1}
TEXINPUTS="/data/common:chapters:$TEXINPUTS"
CMD="pdflatex -interaction=nonstopmode -file-line-error -shell-escape --output-directory=../build/${1} main.tex"
./run-in-docker.sh /bin/bash -c "export TEXINPUTS=\"${TEXINPUTS}\"; cd ${1}; ${CMD}; ${CMD}"

