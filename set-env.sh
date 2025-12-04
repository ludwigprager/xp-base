
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
export CLOUDSDK_CORE_PROJECT=${XP_BASE_GCP_PROJECT}
# GCP service account
SA_NAME="crossplane"

VM_USER=user1
SSH_KEY_NAME="id_ed25519_crossplane"
