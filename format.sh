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

FORMATTER="$SCRIPT_DIRECTORY/.latexindent.x"
FM_VERSION="3.24.5"

# Just download latexindent to not bother with docker here
if [ ! -f "$FORMATTER" ] || [ ! -x "$FORMATTER" ] || [ "$("$FORMATTER" --version | cut -d ',' -f 1)" != "$FM_VERSION" ]; then
	FM_ARCH="$(uname -s)/$(uname -m)"
	case "$FM_ARCH" in
	"Darwin/"*)
		FM_DOWNLOAD="latexindent-macos"
		;;
	"Linux/x86_64" | "Linux/amd64")
		FM_DOWNLOAD="latexindent-linux"
		;;
	"Linux/aarch64")
		FM_DOWNLOAD="latexindent-linux-arm64"
		;;
	*)
		crash "no latexindent version found for $FM_ARCH"
		;;
	esac

	FM_SOURCE="https://github.com/cmhughes/latexindent.pl/releases/download/V$FM_VERSION/$FM_DOWNLOAD"

	if type curl &>/dev/null; then
		echo "Downloading latex-indent via curl..."
		curl -L "$FM_SOURCE" --output "$FORMATTER"
	elif type wget &>/dev/null; then
		echo "Downloading latex-indent via wget..."
		wget "$FM_SOURCE" -O "$FORMATTER"
	elif type lwp-request &>/dev/null; then
		echo "Downloading latex-indent via lwp-request"
		lwp-request -m 'GET' "$FM_SOURCE" >"$FORMATTER"
	else
		echo "$PROGNAME: error: no tool found to download formatter"
		echo "$PROGNAME: note: install curl, wget or lwp-request"
		exit 1
	fi
	chmod +x "$FORMATTER"
fi

[ $# -eq 1 ] || crash "expected a file or directory"

if [ -f "${1}" ]; then
	bold "Formatting file ${1}..."
	"$FORMATTER" --overwrite --silent "${1}"
	bold "Removing created backup..."
	rm "$(dirname "${1}")/$(basename "${1}" .tex).bak0"
	bold "Removing created log..."
	rm -f "./indent.log"
elif [ -d "${1}" ]; then
	cd "${1}" || crash "cannot enter directory"
	bold "Removing previous backups..."
	find . -type f -name '*.bak0' -exec sh -c 'echo "Removing $1..." && rm "$1"' _ {} ';'
	bold "Formatting directory ${1}..."
	find . -type f -name '*.tex' -print0 | xargs -0 -n 1 -P 8 sh -c 'echo "Formatting $2..." && "$1" --overwrite --silent "$2"' _ "$FORMATTER"
	bold "Removing created backups..."
	find . -type f -name '*.bak0' -exec sh -c 'echo "Removing $1..." && rm "$1"' _ {} ';'
	bold "Removing created logs..."
	find . -type f -name 'indent.log' -exec sh -c 'echo "Removing $1..." && rm "$1"' _ {} ';'
else
	crash "not a normal file or directory"
fi
