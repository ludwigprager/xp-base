#!/usr/bin/env bash

set -eu
BASEDIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
cd $BASEDIR

source .env

if [[ ! -f ./bucketname.txt ]]; then
  echo "upbound-bucket-"$(head -n 4096 /dev/urandom | openssl sha1 | tail -c 10) > ./bucketname.txt
fi

export BUCKETNAME=$(cat ./bucketname.txt)

#envsubst < gcp/bucket.yaml.tpl | ./bin/kubectl apply -f -


# Check if ssh key already exists
if [[ ! -f "$SSH_KEY_NAME" ]]; then
  echo "creating ssh key $SSH_KEY_NAME"

  # Generate the key pair
  ssh-keygen -t ed25519 -f "$SSH_KEY_NAME" -C "crossplane" -N ""

  echo "SSH key pair generated:"
  echo "Private key: $SSH_KEY_NAME"
  echo "Public key:  $SSH_KEY_NAME.pub"

fi

echo "Waiting before creating a VM"

# 1. Wait for Crossplane system to be ready
kubectl wait --for=condition=ready pod \
  -l app=crossplane \
  -n crossplane-system \
  --timeout=300s

# 2. Wait for GCP provider to be ready
kubectl wait --for=condition=ready pod \
  -l pkg.crossplane.io/provider=provider-gcp-compute \
  -n crossplane-system \
  --timeout=300s

# ---

# debug:
kubectl -n crossplane-system get pods -l pkg.crossplane.io/provider=provider-gcp-compute
#kubectl -n crossplane-system logs deployment/provider-gcp-compute --all-containers
kubectl -n crossplane-system get svc provider-gcp-compute
kubectl get provider.pkg
kubectl get providerrevision
kubectl -n crossplane-system get pods
kubectl logs -n crossplane-system $(kubectl get deploy -n crossplane-system -o name | grep provider-gcp-compute) || true


export VM_USER
export PUBLIC_KEY=$(echo "$(cut -d ' ' -f1-2 ${SSH_KEY_NAME}.pub)")

envsubst < gcp/vm.yaml.tpl | ./bin/kubectl apply -f -
envsubst < gcp/network.yaml.tpl | ./bin/kubectl apply -f -

