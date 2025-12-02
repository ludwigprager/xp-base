#!/usr/bin/env bash

function go-in-docker() {
  local command="$*"

  docker run -ti --rm \
    -w /work \
    -v $(pwd):/work/ \
    -e GOMODCACHE=/work/go/ \
    -e GOCACHE=/work/go/build-cache \
    golang:1.24.9 \
    $command
}
export -f go-in-docker
