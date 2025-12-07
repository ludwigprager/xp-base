#!/usr/bin/env bash
set -eu
BASEDIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
cd $BASEDIR
IMAGE_NAME=gcr.io/google.com/cloudsdktool/google-cloud-cli:slim
source ../set-env.sh
# Ensure config directory exists
mkdir -p "$PWD/.gcloud-config"
mkdir -p "$PWD/.podman-images"

if [ -t 1 ]; then
    # stdout is a terminal - don't filter to preserve real-time output
    podman run --rm -ti \
        -v "$PWD:/workspace" \
        -v "$PWD/.gcloud-config:/gcloud-home/.config/gcloud" \
        -e CLOUDSDK_CONFIG=/gcloud-home/.config/gcloud \
        -e HOME=/gcloud-home \
        $IMAGE_NAME \
        gcloud "$@"
else
    # stdout is redirected/piped - filter carriage returns
    podman run --rm -i \
        -v "$PWD:/workspace" \
        -v "$PWD/.gcloud-config:/gcloud-home/.config/gcloud" \
        -e CLOUDSDK_CONFIG=/gcloud-home/.config/gcloud \
        -e HOME=/gcloud-home \
        $IMAGE_NAME \
        gcloud "$@" 2>&1 | col -b
fi
