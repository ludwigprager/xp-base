#!/usr/bin/env bash

set -euo pipefail
BASEDIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
cd $BASEDIR

source .env


timeout=60   # seconds
interval=3
elapsed=0

while (( elapsed < timeout )); do
    if TAGS=$(./misc/gcloud.sh compute instances describe "$GCP_VM_NAME" \
        --project="$CLOUDSDK_CORE_PROJECT" \
        --zone="$GCP_VM_ZONE" \
        --format="get(tags.items)" 2>/dev/null); then
        echo "VM is ready. Tags: $TAGS"
        break
    fi

    echo "VM not found. Retrying in 3 seconds..."
    sleep "$interval"
    elapsed=$(( elapsed + interval ))
done



if ! ./misc/gcloud.sh compute firewall-rules describe allow-wireguard &>/dev/null; then
./misc/gcloud.sh compute firewall-rules create allow-wireguard \
    --direction=INGRESS \
    --priority=1000 \
    --network=default \
    --action=ALLOW \
    --rules=udp:51820,tcp:80,tcp:443 \
    --target-tags=wireguard-server \
    --source-ranges=0.0.0.0/0
fi

TAGS=$(./misc/gcloud.sh compute instances describe wg-vm \
    --zone=${GCP_VM_ZONE} \
    --format="get(tags.items)")

if [[ ! "$TAGS" =~ wireguard-server ]]; then
./misc/gcloud.sh compute instances add-tags wg-vm \
    --tags=wireguard-server \
    --zone=${GCP_VM_ZONE}
fi


echo "Copying script to VM and executing"
ADDRESS=$(kubectl get instances wg-vm  -o json | jq -r .status.atProvider.networkInterface[0].accessConfig[].natIp)
scp -F misc/ssh-config -i ${SSH_KEY_NAME} misc/start-vpn.sh ${VM_USER}@$ADDRESS:

./ssh-to-vm.sh bash -x ./start-vpn.sh $VM_USER

if [[ $? -ne 0 ]]; then
    echo "Remote setup failed!"
    exit 1
fi



URL="http://$ADDRESS/client-1.conf.png"
URL="http://$ADDRESS/client-2.conf.png"

if command -v xdg-open > /dev/null; then
    xdg-open "$URL"  # Linux
elif command -v open > /dev/null; then
    open "$URL"      # macOS
elif command -v start > /dev/null; then
    start "$URL"     # Windows (Git Bash)
else
    echo "Cannot detect browser opener"
fi
