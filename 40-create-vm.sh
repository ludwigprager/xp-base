#!/usr/bin/env bash

set -eu
BASEDIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
cd $BASEDIR

source .env

if [[ ! -f ./bucketname.txt ]]; then
  echo "upbound-bucket-"$(head -n 4096 /dev/urandom | openssl sha1 | tail -c 10) > ./bucketname.txt
fi

export BUCKETNAME=$(cat ./bucketname.txt)

envsubst < gcp/bucket.yaml.tpl | ./bin/kubectl apply -f -

export VM_USER
export PUBLIC_KEY=$(echo "$(cut -d ' ' -f1-2 ~/.ssh/id_ed25519.pub)")

envsubst < gcp/vm.yaml.tpl | ./bin/kubectl apply -f -

