#!/bin/bash

set -eu
BASEDIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
cd $BASEDIR

source .env

#get-kubeconfig

while true; do
  clear

    kubectl get events \
            --sort-by='.metadata.creationTimestamp' -A \
            | tail -n 15
    echo
  sleep 10
done

