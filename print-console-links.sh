#!/usr/bin/env bash

set -eu
BASEDIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
cd $BASEDIR

source .env

echo "GCP console: https://console.cloud.google.com/welcome/new?project=${CLOUDSDK_CORE_PROJECT}"

echo "Buckets: https://console.cloud.google.com/storage/browser?project=${CLOUDSDK_CORE_PROJECT}&forceOnBucketsSortingFiltering=true&bucketType=live"

echo "Service accounts: https://console.cloud.google.com/iam-admin/serviceaccounts?project=${CLOUDSDK_CORE_PROJECT}"

echo "VMs: https://console.cloud.google.com/compute/instances?referrer=search&project=${CLOUDSDK_CORE_PROJECT}"
echo "Billing: https://console.cloud.google.com/billing/01A374-8E0BAA-0C3EE6?project=${CLOUDSDK_CORE_PROJECT}"



