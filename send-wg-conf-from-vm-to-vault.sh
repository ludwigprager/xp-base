#!/usr/bin/env bash
# send-wg-conf-from-vm-to-vault.sh
set -euo pipefail
BASEDIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
cd "$BASEDIR"
source .env  # should define VAULT_TOKEN, VAULT_ADDR, GCP_VM_NAME, VM_USER, SSH_KEY_NAME

# Get VM address
echo "Getting VM address for ${GCP_VM_NAME}..."
ADDRESS=$(kubectl get instances "${GCP_VM_NAME}" -o json | jq -r '.status.atProvider.networkInterface[0].accessConfig[].natIp')

if [[ -z "$ADDRESS" || "$ADDRESS" == "null" ]]; then
    echo "Error: Could not get VM address"
    exit 1
fi

echo "VM address: ${ADDRESS}"

# Vault path for the WireGuard YAML
WG_SECRET_PATH="wg-config/${GCP_VM_NAME}.wg.yaml"
LOCAL_FILE="${GCP_VM_NAME}.wg.yaml"
REMOTE_FILE="wireguard-container/wg.yaml"

# Check if Vault is accessible
if [[ -n "${VAULT_ADDR:-}" ]]; then
    if ! vault status &>/dev/null; then
        echo "Error: Cannot connect to Vault at ${VAULT_ADDR}"
        exit 1
    fi
    
    # Only fetch and store if secret does not exist
    if ! vault kv get -field=wg_yaml "$WG_SECRET_PATH" &>/dev/null; then
        echo "wg.yaml for ${GCP_VM_NAME} not found in vault -> fetching from vm and storing in vault"
        
        # Retrieve the file via SCP with SSH key
        scp -F misc/ssh-config -i "${SSH_KEY_NAME}" "${VM_USER}@${ADDRESS}:${REMOTE_FILE}" "$LOCAL_FILE"
        
        # Store the file content in Vault (using @ to preserve formatting)
        vault kv put "$WG_SECRET_PATH" wg_yaml=@"$LOCAL_FILE"
        
        echo "✓ Stored wg.yaml in Vault"
    else
        echo "wg.yaml for ${GCP_VM_NAME} already exists in Vault"
    fi
else
    echo "Error: VAULT_ADDR not set"
    exit 1
fi
