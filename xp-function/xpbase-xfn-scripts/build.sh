#!/usr/bin/env bash

set -eu

BASEDIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
cd $BASEDIR

source ../../.env
source misc/utils.sh

TAG=${REGISTRY_FQDN}/ludwigprager/runtime:1.0

# Run code generation - see input/generate.go
go-in-docker go generate ./...

# Run tests - see fn_test.go
# go-in-docker go test ./...

# Build the function's runtime image - see Dockerfile
#docker build . --tag=$TAG

../local-registry/build-and-push.sh
docker build --tag=$TAG .


# Build a function package - see package/crossplane.yaml
crossplane xpkg build -f package --embed-runtime-image=$TAG

#kind load docker-image $TAG --name $CLUSTER


crossplane xpkg build -f package --embed-runtime-image=$TAG -o bla.xpkg
#crossplane xpkg build -f package --embed-runtime-image=$TAG -o - | \
#  crossplane xpkg push registry.g1/function-xbuckets:1.0 -
