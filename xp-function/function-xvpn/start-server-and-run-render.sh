#!/usr/bin/env bash

set -eu

BASEDIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
cd $BASEDIR

source ../../.env

cleanup() {
    # Always try to remove, ignore errors
    docker rm -f function-xvpn >/dev/null 2>&1 || true
}
trap cleanup EXIT

./generate.sh

docker run -d --rm \
    --name=function-xvpn \
    --network=host \
    -w /work \
    -v $(pwd):/work/ \
    -e GOMODCACHE=/work/.go-mod-cache \
    -e GOCACHE=/work/.go-build-cache \
    golang:1.24.9 \
    go run . --insecure --debug

#docker logs -f function-xvpn &

crossplane render xr.yaml composition.yaml functions.yaml

docker rm -f function-xvpn
