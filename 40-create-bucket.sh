#!/usr/bin/env bash

set -eu
BASEDIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
cd $BASEDIR



source set-env.sh
source .env

if [[ ! -f ./bucketname.txt ]]; then
  echo "upbound-bucket-"$(head -n 4096 /dev/urandom | openssl sha1 | tail -c 10) > ./bucketname.txt
fi

export BUCKETNAME=$(cat ./bucketname.txt)

envsubst < gcp/bucket.tpl | ./bin/kubectl apply -f -

