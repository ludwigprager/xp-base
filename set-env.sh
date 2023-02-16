
CLUSTER="cb-$(whoami)"
#PS1="[xp-base ${GCB:-undefined} ]\$ "
PS1="[xp-base]\$ "

# GCP settings
# GCP project
export CLOUDSDK_CORE_PROJECT=${XP_BASE_GCP_PROJECT}
# GCP service account
SA_NAME="crossplane"
