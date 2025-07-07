#!/usr/bin/env bash
set -eu

PROGNAME="$0"
crash() {
	echo "$PROGNAME: error: $1"
	exit 1
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
[ -f "./build-one.sh" ] || crash "build-one.sh script not found"
[ -x "./build-one.sh" ] || crash "build-one.sh script found, but is not executable"

if type docker >/dev/null 2>/dev/null; then
	DOCKER_CMD=docker
elif type podman >/dev/null 2>/dev/null; then
	DOCKER_CMD=podman
elif [ -z "${DOCKER_CMD:-}" ]; then
	echo "$PROGNAME: error: no docker/podman command found"
	echo "$PROGNAME: note: you can set DOCKER_CMD variable to the correct docker-compatible executable"
	exit 1
fi

DOCKER_IMAGE="ghcr.io/xu-cheng/texlive-full:latest"
"$DOCKER_CMD" run --rm --net=none -v "$SCRIPT_DIRECTORY:/data/:z" \
	-v "$SOURCE_DIRECTORY:/src/:z" -e TEXINPUTS \
	"$DOCKER_IMAGE" sh /data/build-one.sh "/src/"
