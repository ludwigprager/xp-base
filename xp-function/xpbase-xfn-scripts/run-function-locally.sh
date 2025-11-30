#!/usr/bin/env bash

set -eu

BASEDIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
cd $BASEDIR

#source ../../.env
source utils.sh

./generate.sh

go-in-docker go run . --insecure --debug

