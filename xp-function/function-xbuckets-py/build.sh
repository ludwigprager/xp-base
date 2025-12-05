#!/usr/bin/env bash

set -eu
BASEDIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
cd $BASEDIR

source ../../set-env.sh
source ./set-env.sh


docker exec -ti builder \
  docker build -q --tag=$RUNTIME_TAG /work/"$THIS_DIR"

docker exec -ti xpkg \
  crossplane xpkg build \
    --package-root=$THIS_DIR/package \
    --package-file=$THIS_DIR/function-xbuckets-py.xpkg
#   --embed-runtime-image=$RUNTIME_TAG \

