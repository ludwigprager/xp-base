#!/usr/bin/env bash

set -eu
BASEDIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
cd $BASEDIR

source ../../set-env.sh

mkdir -p certs/${REGISTRY_FQDN}

./self-signed-certificate/create-root-CA-and-self-signed-certificate.sh

cp self-signed-certificate/myCA/certs/myCA.crt certs/${REGISTRY_FQDN}
cp self-signed-certificate/certs/registry.g1.key certs/
cp self-signed-certificate/certs/registry.g1.crt certs/

# Make Kind nodes trust the self-signed cert

for node in $(docker ps -qf "name=${CLUSTER}*"); do
    #docker exec -ti $node cat /etc/issue
    docker cp certs/registry.g1.crt $node:/usr/local/share/ca-certificates/registry.g1.crt
    docker cp certs/registry.g1/myCA.crt $node:/usr/local/share/ca-certificates/
    docker exec -ti $node update-ca-certificates
    docker exec -ti $node systemctl restart containerd
done

# cp self-signed-certificate/registry.g1.* certs/

docker compose up -d
