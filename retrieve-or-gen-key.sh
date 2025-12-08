#!/usr/bin/env bash
set -euo pipefail
BASEDIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
cd "$BASEDIR"
source .env  # should define SSH_KEY_NAME and VAULT_PATH

# Function to retrieve keys from Vault
retrieve_from_vault() {
    echo "Retrieving ssh keys from vault"
    vault kv get -field=private_key "$VAULT_PATH" > "$SSH_KEY_NAME"
    vault kv get -field=public_key "$VAULT_PATH" > "${SSH_KEY_NAME}.pub"
    chmod 600 "$SSH_KEY_NAME"
    chmod 644 "${SSH_KEY_NAME}.pub"
}

# Function to generate new SSH key pair
generate_key() {
    echo "Generating ssh keys"
    ssh-keygen -t ed25519 -f "$SSH_KEY_NAME" -C "crossplane" -N ""
}

# Function to store keys in Vault
store_in_vault() {
    echo "Storing keys in Vault"
    # Use @ prefix to read from file, which preserves formatting
    vault kv put "$VAULT_PATH" \
        private_key=@"$SSH_KEY_NAME" \
        public_key=@"${SSH_KEY_NAME}.pub"
}

# Main logic
if [[ -n "${VAULT_ADDR:-}" ]]; then
    if vault kv get -field=private_key "$VAULT_PATH" &>/dev/null; then
        # Secret exists in Vault → retrieve it
        retrieve_from_vault
    else
        # Secret missing in Vault → generate key if missing locally
        [[ -f "$SSH_KEY_NAME" ]] || generate_key
        # Store generated keys in Vault
        store_in_vault
    fi
else
    # Vault not set → generate key if missing locally
    [[ -f "$SSH_KEY_NAME" ]] || generate_key
fi

echo "✓ Done"
