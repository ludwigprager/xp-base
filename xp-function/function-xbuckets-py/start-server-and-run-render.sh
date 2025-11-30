#!/usr/bin/env bash

set -eu

BASEDIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
cd $BASEDIR

source ../../.env
#source utils.sh

#TAG=${REGISTRY_FQDN}/ludwigprager/runtime:1.0

deactivate || true

if [[ ! -f venv ]]; then
  python3 -m venv venv
  source venv/bin/activate
  pip3 install hatch
fi

source venv/bin/activate

setsid hatch run development &
PGID=$!

crossplane render xr.yaml composition.yaml functions.yaml

# The minus sign is the key → means: “kill the whole process group with this PGID”.
kill -TERM -"$PGID"
deactivate


