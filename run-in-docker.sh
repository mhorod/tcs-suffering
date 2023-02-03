#!/bin/sh
# from: https://github.com/blang/latex-docker
IMAGE=blang/latex:ubuntu
exec docker run --rm -i --user="$(id -u):$(id -g)" --net=none -v "$PWD":/data "$IMAGE" "$@"
