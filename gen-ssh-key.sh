#!/usr/bin/env bash
set -euo pipefail
BASEDIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
cd "$BASEDIR"
source .env  # should define SSH_KEY_NAME and VAULT_PATH


# Function to generate new SSH key pair
generate_key() {
    echo "Generating ssh keys"
    ssh-keygen -t ed25519 -f "$SSH_KEY_NAME" -C "crossplane" -N ""
}

# generate key if missing locally
[[ -f "$SSH_KEY_NAME" ]] || generate_key

echo "✓ Done"
