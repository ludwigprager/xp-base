#!/usr/bin/env bash

set -eu
BASEDIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
cd $BASEDIR

source .env

./xp-function/function-vpn/build.sh 

: '
#docker build -t your-dockerhub-user/function-hello:latest .
docker build -t ludwigprager/function-hello:latest functions-demo/function-hello/

docker push ludwigprager/function-hello:latest

kubectl apply -f functions-demo/function-hello/function.yaml 

kubectl apply -f functions-demo/xrd.yaml 
kubectl apply -f functions-demo/composition.yaml 
kubectl apply -f functions-demo/claim.yaml 


# test

kubectl get sqlinstance
kubectl describe sqlinstance <name>
kubectl logs -l pkg.crossplane.io/function=function-hello -n crossplane-system
'

kubectl apply -f xp-function/v2/xrd.yaml
kubectl apply -f xp-function/v2/functiondefinition.yaml
#kubectl apply -f xp-function/v2/composition.yaml
#kubectl apply -f xp-function/v2/claim.yaml

