#!/usr/bin/env bash

set -eu
BASEDIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
cd $BASEDIR

./20-start-mgmt-cluster.sh
./30-prepare-for-gcp.sh 
./40-create-bucket.sh
./50-xp-function.sh
