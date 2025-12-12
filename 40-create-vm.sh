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

./gen-ssh-key.sh

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

echo "Extra waits:"

# Wait for the provider pod to be ready
kubectl wait --for=condition=ready pod \
  -l pkg.crossplane.io/provider=provider-gcp-compute \
  -n crossplane-system \
  --timeout=300s

# Wait for the webhook service to have endpoints
kubectl wait --for=jsonpath='{.subsets[*].addresses[*].ip}' endpoints \
  provider-gcp-compute \
  -n crossplane-system \
  --timeout=300s

# Check if the conversion webhook is registered and ready
kubectl get crd instances.compute.gcp.upbound.io -o jsonpath='{.spec.conversion.webhook.clientConfig.service}'

# Verify the service exists and has endpoints
kubectl get endpoints provider-gcp-compute -n crossplane-system

echo "Waiting for GCP provider webhook to be ready..."

## Wait for deployment to be available
#kubectl wait --for=condition=available deployment \
#  -l pkg.crossplane.io/provider=provider-gcp-compute \
#  -n crossplane-system \
#  --timeout=300s
#

# Wait for the provider deployment (it has a hash suffix)
kubectl wait --for=condition=available deployment \
  -l pkg.crossplane.io/provider=provider-gcp-compute \
  -n crossplane-system \
  --timeout=300s 2>/dev/null || \
kubectl wait --for=condition=available deployment \
  -l app.kubernetes.io/name=provider-gcp-compute \
  -n crossplane-system \
  --timeout=300s 2>/dev/null || \
#kubectl wait --for=condition=available deployment \
#  -n crossplane-system \
#  -l pkg.crossplane.io/revision \
#  --timeout=300s
#

echo "Waiting for GCP provider webhook to be ready..."

# Wait for any deployment starting with provider-gcp-compute
DEPLOYMENT=$(kubectl get deployment -n crossplane-system -o name | grep provider-gcp-compute)

if [ -n "$DEPLOYMENT" ]; then
  kubectl wait --for=condition=available \
    $DEPLOYMENT \
    -n crossplane-system \
    --timeout=300s
else
  echo "No provider-gcp-compute deployment found"
  exit 1
fi

# Wait for the webhook service to have endpoints
if kubectl get service provider-gcp-compute -n crossplane-system &>/dev/null; then
  kubectl wait --for=jsonpath='{.subsets[*].addresses[*].ip}' \
    endpoints/provider-gcp-compute \
    -n crossplane-system \
    --timeout=300s

  echo "Waiting 10s for webhook registration..."
#  sleep 10
else
  echo "Warning: provider-gcp-compute service not found"
fi

echo "Ready to apply resources"





envsubst < gcp/vm.yaml.tpl | ./bin/kubectl apply -f -

