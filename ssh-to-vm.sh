#!/usr/bin/env bash

set -eu
BASEDIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
cd $BASEDIR

source .env

ADDRESS=$(kubectl get instances wg-vm  -o json | jq -r .status.atProvider.networkInterface[0].accessConfig[].natIp)

ssh -i ${SSH_KEY_NAME} ${VM_USER}@$ADDRESS

