#!/usr/bin/env bash

set -eu
BASEDIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
cd $BASEDIR

source ../../set-env.sh

RUNTIME_IMAGE=ludwigprager/function-xbuckets-py
PACKAGE_IMAGE=ludwigprager/xbuckets-py
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
docker exec -ti xpkg \
  curl -k https://registry.g1/v2/${RUNTIME_IMAGE}/tags/list

docker exec -ti xpkg \
  crossplane xpkg build \
    --package-root=$THIS_DIR/package \
    --package-file=$THIS_DIR/function-xbuckets-py.xpkg
#   --embed-runtime-image=$RUNTIME_TAG \

# test registry access via xpkg:
docker exec -ti xpkg curl https://registry.g1/v2/${RUNTIME_IMAGE}/tags/list

docker exec -ti xpkg \
  crossplane xpkg push \
    --package-files=$THIS_DIR/function-xbuckets-py.xpkg \
    $PACKAGE_TAG

docker exec -ti xpkg curl https://registry.g1/v2/${PACKAGE_IMAGE}/tags/list
