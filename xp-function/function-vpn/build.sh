#!/usr/bin/env bash

set -eu

BASEDIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
cd $BASEDIR

source ../../set-env.sh
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

#if [[ ! -f go.mod ]]; then
#  go-in-docker go mod init wg-config
#fi

#if [[ ! -f go.sum ]]; then
#  go-in-docker go get \
#    gopkg.in/yaml.v2 \
#    github.com/davecgh/go-spew/spew \
#    golang.zx2c4.com/wireguard/wgctrl/wgtypes
#fi

#go-in-docker go build main.go
#go-in-docker gofmt -w main.go


#mkdir -p config-files
#go-in-docker ./main config-files

# Run code generation - see input/generate.go
go-in-docker go generate ./...

# Run tests - see fn_test.go
# go-in-docker go test ./...

# Build the function's runtime image - see Dockerfile
docker build . --tag=runtime:latest

# Build a function package - see package/crossplane.yaml
crossplane xpkg build -f package --embed-runtime-image=runtime

kind load docker-image runtime:latest --name $CLUSTER

