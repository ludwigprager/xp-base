#!/usr/bin/env bash

set -eu
BASEDIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
cd $BASEDIR

KUBECTL_VERSION=${1:-1.30.2}
NODE_VERSION=${2:-1.30.0}

source set-env.sh

mkdir -p ./bin

if [[ ! -f ./bin/kubectl ]]; then
  KUBECTL_VERSION=1.34.0
  curl -Lo ./bin/kubectl https://dl.k8s.io/release/v$KUBECTL_VERSION/bin/linux/amd64/kubectl
  chmod +x ./bin/kubectl
fi

if [[ ! -f ./bin/helm ]]; then
  HELM_VERSION=3.13.1
  curl -LO https://get.helm.sh/helm-v${HELM_VERSION}-linux-amd64.tar.gz
  tar zxvf helm-v${HELM_VERSION}-linux-amd64.tar.gz
  chmod +x linux-amd64/helm
  mv linux-amd64/helm ./bin/
fi


if [[ ! -f ./bin/kind ]]; then
  KIND_VERSION=0.30.0
  echo downloading kind $KIND_VERSION
  curl -Lo ./kind https://kind.sigs.k8s.io/dl/v${KIND_VERSION}/kind-linux-amd64
  chmod +x ./kind
  mv kind bin/
fi

export BASEDIR
export XP_BASE_ROOT=$(git rev-parse --show-toplevel)
export HOSTNAME=$(hostname)
export HOST_IP=$(ip addr show docker0 | grep -Po 'inet \K[\d.]+')

envsubst < ./misc/env.tpl > .env
cat set-env.sh >> .env
cat misc/utils.sh >> .env
source .env

kubectl completion bash | sed 's/kubectl/k/g' >> .env
test -f /etc/bash_completion && cat /etc/bash_completion >> .env


if ! kind-cluster-exists $CLUSTER; then
  echo "Creating management cluster"

  # curl -LO https://raw.githubusercontent.com/cilium/cilium/1.15.6/Documentation/installation/kind-config.yaml 
  kind create cluster \
    -n $CLUSTER \
    --config ./misc/kind.config \
    --image kindest/node:v${NODE_VERSION}
fi


if [[ ! -f ./bin/up ]]; then
  echo "Installing the Up command-line"
  curl -sL "https://cli.upbound.io" | UP_VERSION=v0.42.1 sh
  mv up bin/
  up version
fi

if kubectl get deployment -n crossplane-system crossplane -o name >/dev/null 2>&1; then
  echo "UXP already installed"
else
  up uxp install
fi

if [[ ! -f ./bin/crossplane ]]; then
  echo "Installing the crossplane cli"
  curl -sL "https://raw.githubusercontent.com/crossplane/crossplane/main/install.sh" | XP_VERSION=v2.1.1 sh
  mv crossplane bin/
fi


echo "Waiting for crossplane to get available"
./bin/kubectl wait --for=condition=available --timeout=300s \
  deployment/crossplane -n crossplane-system


# update coredns corefile

# kubectl -n kube-system get configmap coredns -o yaml | yq .data.Corefile > Corefile
kubectl -n kube-system create configmap coredns \
  --from-file=Corefile=./misc/Corefile \
  --dry-run=client -o yaml | kubectl apply -f -

kubectl -n kube-system rollout restart deployment coredns
kubectl -n kube-system get pods -l k8s-app=kube-dns
kubectl run -i --tty --rm testpod --image=busybox --restart=Never -- nslookup registry.g1


