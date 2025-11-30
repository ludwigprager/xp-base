#!/usr/bin/env bash

set -eu
BASEDIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
cd $BASEDIR

source ../../set-env.sh

docker exec -ti builder docker build --tag=$REGISTRY_FQDN/ludwigprager/runtime:1.0 /work/function-vpn/
docker exec -ti builder docker push $REGISTRY_FQDN/ludwigprager/runtime:1.0

