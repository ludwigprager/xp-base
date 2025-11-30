#!/usr/bin/env bash

set -eu
BASEDIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
cd $BASEDIR

source ../../set-env.sh

RUNTIME_IMAGE=ludwigprager/function-xbuckets-py
PACKAGE_IMAGE=ludwigprager/function-xbuckets
VERSION=1.0
RUNTIME_TAG=$REGISTRY_FQDN/${RUNTIME_IMAGE}:$VERSION
PACKAGE_TAG=$REGISTRY_FQDN/${PACKAGE_IMAGE}:$VERSION

echo RUNTIME_TAG=$RUNTIME_TAG
echo PACKAGE_TAG=$PACKAGE_TAG

THIS_DIR=$(basename $(realpath .))

docker exec -ti builder docker \
  build --tag=$RUNTIME_TAG /work/"$THIS_DIR"
docker exec -ti builder \
  docker push $RUNTIME_TAG


# show the registry folder
curl -k https://registry.g1/v2/${RUNTIME_IMAGE}/tags/list

docker exec -ti builder \
  crossplane xpkg build \
    --package-root=$THIS_DIR/package \
    --embed-runtime-image=$RUNTIME_TAG \
    --package-file=$THIS_DIR/function-xbuckets.xpkg


# test registry access via xpkg:
docker exec -ti xpkg curl https://registry.g1/v2/${RUNTIME_IMAGE}/tags/list


docker exec -ti xpkg \
  crossplane xpkg push \
    --package-files=$THIS_DIR/function-xbuckets.xpkg \
    $PACKAGE_TAG

docker exec -ti xpkg \
  curl https://registry.g1/v2


