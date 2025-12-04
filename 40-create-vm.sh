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


# Check if ssh key already exists
if [[ ! -f "$KEY_NAME" ]]; then
  echo "creating ssh key $KEY_NAME"

  # Generate the key pair
  ssh-keygen -t ed25519 -f "$KEY_NAME" -C "crossplane" -N ""

  echo "SSH key pair generated:"
  echo "Private key: $KEY_NAME"
  echo "Public key:  $KEY_NAME.pub"

fi





export VM_USER
export PUBLIC_KEY=$(echo "$(cut -d ' ' -f1-2 ${KEY_NAME}.pub)")

envsubst < gcp/vm.yaml.tpl | ./bin/kubectl apply -f -

