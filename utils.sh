#!/usr/bin/env bash




function my-helm() {
  $C_TOOL run --rm \
    --volume $(pwd)/:/work \
    -e KUBECONFIG=/work/kubeconfig \
     --volume ${KUBECONFIG}:/work/kubeconfig \
    -e HELM_CACHE_HOME="/work/helm/.cache/helm" \
    -e HELM_CONFIG_HOME="/work/helm/.config/helm" \
    -e HELM_DATA_HOME="/work/helm/.local/share/helm" \
    -e HELM_PLUGINS="/work/helm/.local/share/helm/plugins" \
    -e HELM_REGISTRY_CONFIG="/work/helm/.config/helm/registry/config.json" \
    -e HELM_REPOSITORY_CACHE="/work/helm/.cache/helm/repository" \
    -e HELM_REPOSITORY_CONFIG="/work/helm/.config/helm/repositories.yaml" \
    ${GCB_TOOLBOX} \
    helm $*
}
export -f my-helm



function cluster-exists() {
  local  cluster_name=$1

  result=$(get-cluster-id $cluster_name)

  if [ -z "$result" ]
  then
    #echo "\$result is empty"
    # 1 = false
    return 1
  else
    #echo "\$result is NOT empty"
    # 0 = true
    return 0 
  fi

# if [[ "$result" == "gs://${cluster_name}/" ]]; then
#   # 0 = true
#   return 0 
# else
#   # 1 = false
#   return 1
# fi

}
export -f cluster-exists

function wait-for-port-forward() {
  local localport=$1
  local start=$(date +%s)
  # wait for $localport to become available
  while ! nc -vz localhost $localport > /dev/null 2>&1 ; do
    # echo sleeping
    sleep 0.1
    now=$(date +%s)
    elapsed=$(($now-$start))
    if [[ $elapsed -gt 5 ]]; then
      echo wait-for-port-forward timed out after 5 seconds
      return
    fi
  done
}

confirm() {
  # call with a prompt string or use a default
  read -r -p "${1:-Are you sure? [y/N]} " response
  case "$response" in
    [yY][eE][sS]|[yY]) 
      true
      ;;
    *)
      false
      ;;
  esac
}
export -f confirm


get-primary-ip() {
  # no hostname -I on macOS
  if [ "$(uname -o)" == Darwin ]; then
    local PRIMARY_IP=$(ifconfig en0 | awk '/inet / {print $2; }' | egrep -v 127.0.0.1 | head -1)
  else
    local PRIMARY_IP=$(hostname -I | cut -d " " -f1)
  fi
  printf ${PRIMARY_IP}
}
export -f get-primary-ip

function kind-cluster-exists() {
  local cluster_name=$1
  local KIND=${BASEDIR}/bin/kind

#echo KIND: $KIND
#echo cluster_name: $cluster_name
  # need a blank after name. Else prefix would work, too.
  COUNT=$(${KIND} get clusters 2>/dev/null  | grep ^${cluster_name} | wc -l)
#echo "${KIND} cluster list"
#echo COUNT: $COUNT
  if [[ $COUNT -eq 0 ]]; then
    # 1 = false
    return 1
  else
    # 0 = true
    return 0
  fi
}

export -f kind-cluster-exists

