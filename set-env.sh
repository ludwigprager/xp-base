
CLUSTER="cb-$(whoami)"
#PS1="[xp-base ${GCB:-undefined} ]\$ "
PS1="[xp-base]\$ "

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

