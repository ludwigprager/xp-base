#!/usr/bin/env bash

set -eu
BASEDIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
cd $BASEDIR

IMAGE_NAME=gcr.io/google.com/cloudsdktool/google-cloud-cli:slim

# source env file to learn CLOUDSDK_CORE_PROJECT
source ../set-env.sh

# Ensure config directory exists
mkdir -p "$PWD/.gcloud-config"
mkdir -p "$PWD/.podman-images"

# Use -it only if stdin is a terminal
if [ -t 0 ]; then
    INTERACTIVE_FLAGS="-it"
else
    INTERACTIVE_FLAGS="-i"
fi

# Run gcloud in Docker
podman run --rm $INTERACTIVE_FLAGS \
    -v "$PWD:/workspace" \
    -v "$PWD/.gcloud-config:/gcloud-home/.config/gcloud" \
    -e CLOUDSDK_CONFIG=/gcloud-home/.config/gcloud \
    -e HOME=/gcloud-home \
    $IMAGE_NAME \
    gcloud "$@"
#   gcloud "$@" | tr -d '\r'
