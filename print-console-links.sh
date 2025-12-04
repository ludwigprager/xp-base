#!/usr/bin/env bash

set -eu
BASEDIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
cd $BASEDIR

source ./set-env.sh

echo "GCP console: https://console.cloud.google.com/welcome/new?project=${CLOUDSDK_CORE_PROJECT}"

echo "Buckets: https://console.cloud.google.com/storage/browser?project=${CLOUDSDK_CORE_PROJECT}&forceOnBucketsSortingFiltering=true&bucketType=live"

echo "Service accounts: https://console.cloud.google.com/iam-admin/serviceaccounts?project=${CLOUDSDK_CORE_PROJECT}"

echo "VMs: https://console.cloud.google.com/compute/instances?referrer=search&project=${CLOUDSDK_CORE_PROJECT}"



exit


#password=$(kubectl get -n argocd secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d)

#PRIMARY_IP=$(get-primary-ip)

#echo
#echo "argocd:              http://${PRIMARY_IP}:${INGRESS_PORT}/argocd/"
#echo "argocd login:        admin : ${password}"
#echo
#echo "guestbook:           http://${PRIMARY_IP}:${INGRESS_PORT}/guestbook"
#echo "helm-guestbook:      http://${PRIMARY_IP}:${INGRESS_PORT}/helm-guestbook/"
#echo "kustomize-guestbook: http://${PRIMARY_IP}:${INGRESS_PORT}/kustomize-guestbook/"
#echo "podinfo              http://${PRIMARY_IP}:${INGRESS_PORT}/podinfo/"
#echo
#echo "fleet repo:          http://$GITEA:3000/explore/repos/"
#echo "swagger:             http://${GITEA}:3000/api/swagger#"
#echo

INDICES_PATH="app/opensearch_index_management_dashboards#/indices"
DISCOVER="app/discover#/"
DISCOVER="https://opensearch-dashboards.${DNS_DOMAIN}/app/data-explorer/discover#?_a=(discover:(columns:!(_source),isDirty:!f,sort:!()),metadata:(indexPattern:c6f321d0-99bf-11ee-a101-a55f895cdbed,view:discover))&_g=(filters:!(),refreshInterval:(pause:!t,value:0),time:(from:now-15m,to:now))&_q=(filters:!(),query:(language:kuery,query:%27%27))"

#sensible-browser http://localhost:8333/$INDICES_PATH || echo "http://$(get-primary-ip):8333/$INDICES_PATH"

echo
#echo "operator ui:  https://postgres-operator-ui.${DNS_DOMAIN}/"
echo "whoami:        https://${DNS_DOMAIN}/whoami"
echo "keycloak:      https://keycloak.${DNS_DOMAIN}/                           admin : admin"
echo "skooner:       https://skooner.${DNS_DOMAIN}/"
echo
echo "registry:      https://${TF_VAR_registry_name}.cr.de-fra.ionos.com/v2/"
echo "letsencrypt:   https://crt.sh/?q=${DNS_DOMAIN}"
