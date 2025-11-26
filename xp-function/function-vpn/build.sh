#!/usr/bin/env bash

set -eu

BASEDIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
cd $BASEDIR

source ../../.env

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

# Run code generation - see input/generate.go
go-in-docker go generate ./...

# Run tests - see fn_test.go
# go-in-docker go test ./...

# Build the function's runtime image - see Dockerfile
docker build . --tag=runtime:latest

# Build a function package - see package/crossplane.yaml
crossplane xpkg build -f package --embed-runtime-image=runtime

kind load docker-image runtime:latest --name $CLUSTER

