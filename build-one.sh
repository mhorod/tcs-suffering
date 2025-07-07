#!/usr/bin/env bash
set -eu

PROGNAME="$0"
crash() {
	echo "$PROGNAME: error: $1"
	exit 1
}

bold() {
	if type tput &>/dev/null; then
		TPUT="tput"
	else
		TPUT="true"
	fi
	$TPUT bold 2>/dev/null || true
	echo "$@"
	$TPUT sgr0 2>/dev/null || true
}

if [ -n "${BASH_SOURCE:-}" ]; then
	PROBABLE_SOURCE="${BASH_SOURCE[0]}"
else
	PROBABLE_SOURCE="$PROGNAME"
fi

# https://stackoverflow.com/questions/59895/how-do-i-get-the-directory-where-a-bash-script-is-located-from-within-the-script
SCRIPT_DIRECTORY="$(cd -- "$(dirname -- "${PROBABLE_SOURCE}")" &>/dev/null && pwd)"

[ $# -eq 1 ] || crash "expected directory as argument"
cd "${1}" || crash "no such source directory"
[ -f "./main.tex" ] || crash "main.tex file not found"

SOURCE_DIRECTORY="$(pwd)"

cd "$SCRIPT_DIRECTORY"
[ -d "./common" ] || crash "common directory not found"

BASENAME="$(basename "$SOURCE_DIRECTORY")"
TEXINPUTS="$(readlink -f ./common):${TEXINPUTS:-}"
export TEXINPUTS

cd "$SOURCE_DIRECTORY"
mkdir -p ../build/"${BASENAME}"
# Execute command twice to generate table of contents
pdflatex -interaction=nonstopmode -file-line-error -shell-escape --output-directory=../build/"${BASENAME}" main.tex
pdflatex -interaction=nonstopmode -file-line-error -shell-escape --output-directory=../build/"${BASENAME}" main.tex

bold "$PROGNAME: succesfully compiled ${BASENAME}"
