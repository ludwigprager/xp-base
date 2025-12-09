#!/usr/bin/env bash

set -eu
BASEDIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
cd $BASEDIR

GCP_VM_NAME=${1:-vpn0}


case "$GCP_VM_NAME" in
  vpn0)
    GCP_VM_ZONE="us-central1-a"
    ;;
  vpn1)
    GCP_VM_ZONE="asia-south2-a"
    ;;
  vpn2)
    GCP_VM_ZONE="asia-east1-a"
    ;;
  *)
    echo "Unknown VM name: $GCP_VM_NAME"
    exit 1
    ;;
esac

echo export GCP_VM_NAME=$GCP_VM_NAME > zone-and-name.sh
echo export GCP_VM_ZONE=$GCP_VM_ZONE >> zone-and-name.sh

bash -x ./20-start-mgmt-cluster.sh
./30-prepare-for-gcp.sh 
./40-create-vm.sh
./50-xp-function.sh
./80-start-vpn.sh
