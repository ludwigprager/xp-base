XP_BASE_ROOT=${XP_BASE_ROOT}

export PS1='$(if [[ $PWD == $XP_BASE_ROOT* ]]; then printf "\[\e[32m\]%s\[\e[0m\]" "${PWD#$XP_BASE_ROOT/}"; else printf "%s" "\w"; fi)\$ '
export PS1='$(if [[ $PWD == $XP_BASE_ROOT ]]; then printf "[ ]"; elif [[ $PWD == $XP_BASE_ROOT/* ]]; then printf "[ %s ]" "${PWD#$XP_BASE_ROOT/}"; else printf "%s" "\w"; fi)\$ '



PATH=$XP_BASE_ROOT/bin:$PATH
alias kubectl=$XP_BASE_ROOT/bin/kubectl
alias k=$XP_BASE_ROOT/bin/kubectl


export HELM_HOME=$XP_BASE_ROOT/my_helm_dir
export HELM_CACHE_HOME=$XP_BASE_ROOT/my_helm_cache_dir
export HELM_DATA_HOME=$XP_BASE_ROOT/my_helm_data_dir
export HELM_CONFIG_HOME=$XP_BASE_ROOT/my_helm_config_dir
export KUBECONFIG=$XP_BASE_ROOT/kubeconfig

#PATH=$XP_BASE_ROOT/functions-demo/go-local/bin/:$PATH

HOSTNAME=${HOSTNAME}.g1
