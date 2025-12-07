
CLUSTER="cb-$(whoami)"
#PS1="[xp-base ${GCB:-undefined} ]\$ "
#PS1="[xp-base]\$ "

export PS1='$(if [[ $PWD == $XP_BASE_ROOT ]]; then printf "[ ]"; elif [[ $PWD == $XP_BASE_ROOT/* ]]; then printf "[ %s ]" "${PWD#$XP_BASE_ROOT/}"; else printf "%s" "\w"; fi)\$ '


# local registry name
#REGISTRY=xp-base.io
#REGISTRY=registry.example.com:5000

REGISTRY_FQDN=registry.example.com
REGISTRY_FQDN=registry.g1

# GCP settings
# GCP project
#export CLOUDSDK_CORE_PROJECT=${XP_BASE_GCP_PROJECT}
GCP_PROJECT_NAME=neptun
export CLOUDSDK_CORE_PROJECT=

#export CLOUDSDK_CORE_PROJECT=${XP_BASE_GCP_PROJECT}
# GCP service account
SA_NAME="crossplane"

VM_USER=user1
SSH_KEY_NAME="id_ed25519_crossplane"

export GCP_VM_NAME="wg-vm"

export GCP_VM_ZONE=europe-west3-c          # Frankfurt
export GCP_VM_ZONE=us-central1-a           # Iowa
export GCP_VM_ZONE=asia-east1-a            # Taiwan
export GCP_VM_ZONE=australia-southeast1-b  # Sydney
export GCP_VM_ZONE=me-west1-b              # Tel Aviv
export GCP_VM_ZONE=southamerica-west1-c    # Santiago de Chile
export GCP_VM_ZONE=southamerica-east1-c	   # Sao Paulo, Brazil
export GCP_VM_ZONE=me-central1-c           # Doha, Qatar
export GCP_VM_ZONE=us-west2-c              # Los Angeles
export GCP_VM_ZONE=us-east4-c              # Ashburn, Virginia
export GCP_VM_ZONE=asia-south2-a           # Delhi
