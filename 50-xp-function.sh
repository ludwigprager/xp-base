#!/usr/bin/env bash

set -eu
BASEDIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
cd $BASEDIR

source .env


./xp-function/local-registry/up.sh

./xp-function/function-xbuckets-py/start-server-and-run-render.sh
./xp-function/function-xbuckets-py/build-and-push.sh

./xp-function/function-xbuckets-go/start-server-and-run-render.sh

./xp-function/function-xvpn/start-server-and-run-render.sh
./xp-function/function-xvpn/build-and-push.sh
