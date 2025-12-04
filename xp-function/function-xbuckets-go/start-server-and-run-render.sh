#!/usr/bin/env bash

set -eu

BASEDIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
cd $BASEDIR

source ../../.env

./generate.sh

docker run -d --rm \
  --name=function-xbuckets-go \
  --network=host \
  -w /work \
  -v $(pwd):/work/ \
  -e GOMODCACHE=/work/go/ \
  -e GOCACHE=/work/go/build-cache \
  golang:1.24.9 \
  go run . --insecure --debug

docker logs -f function-xbuckets-go &
PID=$-
echo $PID

crossplane render xr.yaml composition.yaml functions.yaml

docker rm -f function-xbuckets-go
