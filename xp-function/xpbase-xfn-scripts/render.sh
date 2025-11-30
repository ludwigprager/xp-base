#!/usr/bin/env bash

set -eu

BASEDIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
cd $BASEDIR

source ../../.env

# xr is the claim
crossplane render xr.yaml composition.yaml  functions.yaml 

