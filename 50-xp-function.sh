#!/usr/bin/env bash

set -eu
BASEDIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
cd $BASEDIR

source .env


docker compose  -f container/docker-compose.yaml up -d

./container/build-and-push.sh


#./xp-function/function-vpn/build.sh 

#docker push ${REGISTRY}/ludwigprager/runtime:1.0


kubectl apply -f xp-function/v2/xrd.yaml
kubectl apply -f xp-function/v2/functiondefinition.yaml
kubectl apply -f xp-function/v2/composition.yaml
kubectl apply -f xp-function/v2/claim.yaml

: '
# test
kubectl get sqlinstance
kubectl describe sqlinstance <name>
kubectl logs -l pkg.crossplane.io/function=function-hello -n crossplane-system
'


