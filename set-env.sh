

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
export CLOUDSDK_CORE_PROJECT=

# GCP service account
SA_NAME="xp-base"

VM_USER=user1
SSH_KEY_NAME="id-ed25519-xpbase"

export GCP_PROJECT_NAME=neptun

