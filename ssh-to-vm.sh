#!/usr/bin/env bash

set -eu
BASEDIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
cd $BASEDIR

source .env

ADDRESS=$(kubectl get instances ${GCP_VM_NAME}  -o json | jq -r .status.atProvider.networkInterface[0].accessConfig[].natIp)

ssh -F misc/ssh-config -i ${SSH_KEY_NAME} ${VM_USER}@$ADDRESS $@
