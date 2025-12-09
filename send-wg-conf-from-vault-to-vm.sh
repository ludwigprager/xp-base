#!/usr/bin/env bash
# send-wg-conf-from-vault-to-vm.sh
set -euo pipefail
BASEDIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
cd "$BASEDIR"
source .env  # should define VAULT_TOKEN, VAULT_ADDR, GCP_VM_NAME, VM_USER, SSH_KEY_NAME

# Get VM address
echo "Getting VM address for ${GCP_VM_NAME}..."
#ADDRESS=$(kubectl get instances "${GCP_VM_NAME}" -o json | jq -r '.status.atProvider.networkInterface[0].accessConfig[].natIp')
ADDRESS=$(kubectl get address ${GCP_VM_ZONE}-0 -o jsonpath='{.status.atProvider.address}')


if [[ -z "$ADDRESS" || "$ADDRESS" == "null" ]]; then
    echo "Error: Could not get VM address"
    exit 1
fi

echo "VM address: ${ADDRESS}"

# Vault path for the WireGuard YAML
WG_SECRET_PATH="wg-config/${GCP_VM_NAME}.wg.yaml"
LOCAL_FILE="${GCP_VM_NAME}.wg.yaml"
REMOTE_FILE="wg.yaml"

# Check if Vault is accessible
if [[ -n "${VAULT_ADDR:-}" ]]; then
    if ! vault status &>/dev/null; then
        echo "Error: Cannot connect to Vault at ${VAULT_ADDR}"
        exit 1
    fi
    
    # Check if secret exists
    if vault kv get -field=wg_yaml "$WG_SECRET_PATH" &>/dev/null; then
        echo "Sending wg.yaml from vault to vm"
        
        # Retrieve secret
        vault kv get -field=wg_yaml "$WG_SECRET_PATH" > "$LOCAL_FILE"
        
        # Update the Endpoint IP address in the WireGuard config
        echo "Updating Endpoint IP to ${ADDRESS}..."
	sed -i "s/^  host: [0-9.]*/  host: ${ADDRESS}/" "$LOCAL_FILE"


        
        # Copy to remote VM with SSH key
        scp -F misc/ssh-config -i "${SSH_KEY_NAME}" "$LOCAL_FILE" "${VM_USER}@${ADDRESS}:${REMOTE_FILE}"
        
        echo "✓ Sent wg.yaml to VM with updated IP"
        
        # Optionally remove local file
        # rm -f "$LOCAL_FILE"
    else
        echo "⚠ wg.yaml for ${GCP_VM_NAME} not found in Vault"
        echo "Run send-wg-conf-from-vm-to-vault.sh first to store the config"
        exit 0
    fi
else
    echo "Error: VAULT_ADDR not set"
    exit 1
fi
