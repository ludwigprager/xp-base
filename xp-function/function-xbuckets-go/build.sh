#!/usr/bin/env bash

set -eu

BASEDIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
cd $BASEDIR

source ../../.env
source utils.sh

TAG=${REGISTRY_FQDN}/ludwigprager/runtime:1.0

RUNTIME_IMAGE=ludwigprager/function-xbuckets-go
PACKAGE_IMAGE=ludwigprager/xbuckets-go
VERSION=1.0
RUNTIME_TAG=$REGISTRY_FQDN/${RUNTIME_IMAGE}:$VERSION
PACKAGE_TAG=$REGISTRY_FQDN/${PACKAGE_IMAGE}:$VERSION


# Run code generation - see input/generate.go
go-in-docker go generate ./...

# Run tests - see fn_test.go
# go-in-docker go test ./...

# Build the function's runtime image - see Dockerfile
#docker build . --tag=$TAG

#../local-registry/build-and-push.sh
docker exec builder docker build function-xbuckets-go --tag=$RUNTIME_TAG
docker build --tag=$RUNTIME_TAG .

# Build a function package - see package/crossplane.yaml
crossplane xpkg build -f package --embed-runtime-image=$RUNTIME_TAG

#kind load docker-image $TAG --name $CLUSTER


crossplane xpkg build -f package --embed-runtime-image=$RUNTIME_TAG -o bla.xpkg
#crossplane xpkg build -f package --embed-runtime-image=$TAG -o - | \
#  crossplane xpkg push registry.g1/function-xbuckets:1.0 -

# TODO build in docker, xpkg auch
