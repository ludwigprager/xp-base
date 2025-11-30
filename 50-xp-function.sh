#!/usr/bin/env bash

set -eu
BASEDIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
cd $BASEDIR

source .env


./xp-function/local-registry/up.sh

exit

./xp-function/local-registry/build-and-push.sh

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


