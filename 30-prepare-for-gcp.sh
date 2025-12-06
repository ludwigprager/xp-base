#!/usr/bin/env bash

set -euo pipefail
BASEDIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
cd $BASEDIR



source .env


./misc/setup-gcp-project.sh $GCP_PROJECT_NAME

export CLOUDSDK_CORE_PROJECT=$(./misc/gcloud.sh config get-value project 2>/dev/null | tr -d '\r' )
sed -i "s/^export CLOUDSDK_CORE_PROJECT=.*/CLOUDSDK_CORE_PROJECT=$CLOUDSDK_CORE_PROJECT/" .env




if ./misc/gcloud.sh services list --enabled 2>/dev/null | grep -q '^compute.googleapis.com\ *Compute Engine API'
then
    echo "Compute Engine API is already enabled."
else
    echo "Compute Engine API is not enabled. Enabling now..."
    ./misc/gcloud.sh services enable compute.googleapis.com
    echo "Compute Engine API has been enabled."
fi



#echo "Test: printing existing compute instances"
#./misc/gcloud.sh compute instances list



SA_EMAIL="$SA_NAME@${CLOUDSDK_CORE_PROJECT}.iam.gserviceaccount.com"

# 2. Create a service account for Crossplane
if ./misc/gcloud.sh iam service-accounts list \
    --filter="email:$SA_EMAIL" \
    --format="value(email)" | grep -q "$SA_EMAIL"; then
    echo "Service account $SA_NAME already exists."
else
    echo "Creating service account $SA_NAME"
  ./misc/gcloud.sh iam service-accounts create $SA_NAME \
    --display-name="Crossplane Service Account"


  echo "Waiting for service account $SA_EMAIL to exist..."
  until ./misc/gcloud.sh iam service-accounts describe "$SA_EMAIL" >/dev/null 2>&1; do
    sleep 2
  done
  echo "Service account is ready."
fi




# 3. Grant required roles

# Minimum roles for VM creation:
echo "Granting compute.admin role to sa"
./misc/gcloud.sh projects add-iam-policy-binding $CLOUDSDK_CORE_PROJECT \
  --member="serviceAccount:${SA_EMAIL}" \
  --role="roles/compute.admin"  > /dev/null

echo "Granting iam.serviceAccountUser role to sa"
./misc/gcloud.sh projects add-iam-policy-binding $CLOUDSDK_CORE_PROJECT \
  --member="serviceAccount:${SA_EMAIL}" \
  --role="roles/iam.serviceAccountUser"  > /dev/null


echo "Granting storage.admin role to sa"
# Optional roles (useful but not strictly required):
# If you create disks, snapshots, images
./misc/gcloud.sh projects add-iam-policy-binding $CLOUDSDK_CORE_PROJECT \
  --member="serviceAccount:${SA_EMAIL}" \
  --role="roles/storage.admin"  > /dev/null

JSON_FILE="gcp-credentials.json"

# 4. Create and download the JSON key
./misc/gcloud.sh iam service-accounts keys create /workspace/${JSON_FILE} \
  --iam-account="${SA_EMAIL}"


# Variables
NAMESPACE="upbound-system"
export GCP_SECRET_NAME="gcp-secret"

# Check if JSON file exists
if [ ! -f "misc/$JSON_FILE" ]; then
  echo "Error: $JSON_FILE not found!"
  exit 1
fi

echo "Creating Secret '$GCP_SECRET_NAME' to namespace '$NAMESPACE' "

B64=$(base64 -w0 "./misc/$JSON_FILE")

# Apply the secret using a heredoc
./bin/kubectl apply -f gcp/namespace.yaml

./bin/kubectl apply -f - <<EOF
apiVersion: v1
kind: Secret
metadata:
  name: $GCP_SECRET_NAME
  namespace: $NAMESPACE
type: Opaque
data:
  creds: "$B64"
EOF

#kubectl delete secret gcp-secret -n upbound-system || true
#kubectl create secret generic gcp-secret -n upbound-system --from-file=creds=./gcp-credentials.json



./bin/kubectl apply -f gcp/provider.yaml

echo "Waiting for providers to appear ..."
until kubectl get provider.pkg.crossplane.io/upbound-provider-family-gcp >/dev/null 2>&1; do
  sleep 2
done
until kubectl get provider.pkg.crossplane.io/provider-gcp-compute >/dev/null 2>&1; do
  sleep 2
done

echo "Waiting for provider to get healthy"
kubectl wait provider.pkg.crossplane.io/upbound-provider-family-gcp \
  --for=condition=Healthy \
  --timeout=300s
kubectl wait provider.pkg.crossplane.io/provider-gcp-compute \
  --for=condition=Healthy \
  --timeout=300s
kubectl wait provider.pkg.crossplane.io/provider-gcp-storage \
  --for=condition=Healthy \
  --timeout=300s

echo "creating GCP provider config"
envsubst < gcp/providerconfig.tpl | ./bin/kubectl apply -f -
