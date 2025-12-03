#!/usr/bin/env bash

set -eu
BASEDIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
cd $BASEDIR

source ../../set-env.sh
source ../../.env

mkdir -p certs/${REGISTRY_FQDN}

./self-signed-certificate/create-root-CA-and-self-signed-certificate.sh

# Make Kind nodes trust the self-signed cert

for node in $(docker ps -qf "name=${CLUSTER}*"); do
    #docker exec -ti $node cat /etc/issue
    docker cp self-signed-certificate/certs/registry.g1.crt $node:/usr/local/share/ca-certificates/registry.g1.crt
    docker cp self-signed-certificate/ca/certs/ca.crt $node:/usr/local/share/ca-certificates/
    docker exec -ti $node update-ca-certificates
    docker exec -ti $node systemctl restart containerd
done

# preparations for xpkg
cp self-signed-certificate/ca/certs/ca.crt container/xpkg/
cp self-signed-certificate/certs/registry.g1.fullchain.crt container/xpkg/




docker compose up -d --build

# making the Crossplane controller trust a private registry
# 1. Create a ConfigMap with your CA:

# TODO:
kubectl delete configmap registry-ca -n crossplane-system || true
kubectl create configmap registry-ca \
  --from-file=ca.crt=self-signed-certificate/ca/certs/ca.crt \
  -n crossplane-system

# 2. patch deployment

# 1️⃣ Add the volume if it doesn’t exist
if ! kubectl get deployment crossplane -n crossplane-system -o json | \
    jq -e '.spec.template.spec.volumes[]? | select(.name=="registry-ca")' >/dev/null; then
  kubectl patch deployment crossplane -n crossplane-system --type=json -p='[
    {
      "op": "add",
      "path": "/spec/template/spec/volumes/-",
      "value": {
        "name": "registry-ca",
        "configMap": {
          "name": "registry-ca"
        }
      }
    }
  ]'
fi


# 2️⃣ Add the volumeMount if it doesn’t exist
if ! kubectl get deployment crossplane -n crossplane-system -o json | \
    jq -e '.spec.template.spec.containers[0].volumeMounts[]? | select(.name=="registry-ca")' >/dev/null; then
  kubectl patch deployment crossplane -n crossplane-system --type=json -p='[
    {
      "op": "add",
      "path": "/spec/template/spec/containers/0/volumeMounts/-",
      "value": {
        "name": "registry-ca",
        "mountPath": "/etc/ssl/certs/extra-ca.crt",
        "subPath": "ca.crt"
      }
    }
  ]'
fi


# 3️⃣ Add the environment variable if it doesn’t exist
if ! kubectl get deployment crossplane -n crossplane-system -o json | \
    jq -e '.spec.template.spec.containers[0].env[]? | select(.name=="SSL_CERT_FILE")' >/dev/null; then
  kubectl patch deployment crossplane -n crossplane-system --type=json -p='[
    {
      "op": "add",
      "path": "/spec/template/spec/containers/0/env/-",
      "value": {
        "name": "SSL_CERT_FILE",
        "value": "/etc/ssl/certs/extra-ca.crt"
      }
    }
  ]'
fi


