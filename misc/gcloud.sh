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

#export graphroot=$BASEDIR/./storage
#   --storage-opt "additionalimagestore=/$BASEDIR/.podman-images/" \

# Run gcloud in Docker
podman run --rm -it \
    -v "$PWD:/workspace" \
    -v "$PWD/.gcloud-config:/gcloud-home/.config/gcloud" \
    -e CLOUDSDK_CONFIG=/gcloud-home/.config/gcloud \
    -e CLOUDSDK_CORE_PROJECT=$CLOUDSDK_CORE_PROJECT \
    -e HOME=/gcloud-home \
    $IMAGE_NAME \
    gcloud "$@"

