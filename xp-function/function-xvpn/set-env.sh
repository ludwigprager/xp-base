#!/usr/bin/env bash

set -eu
BASEDIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
cd $BASEDIR

source ../../set-env.sh

RUNTIME_IMAGE=xp/function-xvpn
PACKAGE_IMAGE=xp/xvpn
VERSION=1.0
RUNTIME_TAG=$REGISTRY_FQDN/${RUNTIME_IMAGE}:$VERSION
PACKAGE_TAG=$REGISTRY_FQDN/${PACKAGE_IMAGE}:$VERSION

echo RUNTIME_TAG=$RUNTIME_TAG
echo PACKAGE_TAG=$PACKAGE_TAG

THIS_DIR=$(basename $(realpath .))
