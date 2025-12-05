#!/usr/bin/env bash

set -eu
BASEDIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
cd $BASEDIR

source ../../set-env.sh
source ./set-env.sh


docker exec -ti builder \
  docker push $RUNTIME_TAG

docker exec -ti xpkg \
  crossplane xpkg push \
    --package-files=$THIS_DIR/function-xvpn-py.xpkg \
    $PACKAGE_TAG

# show the registry folder
docker exec -ti xpkg curl https://registry.g1/v2/${RUNTIME_IMAGE}/tags/list
docker exec -ti xpkg curl https://registry.g1/v2/${PACKAGE_IMAGE}/tags/list
docker exec -ti xpkg curl https://registry.g1/v2/_catalog

echo << EOF
use the package later with this command:
kubectl crossplane install $PACKAGE_TAG
EOF
