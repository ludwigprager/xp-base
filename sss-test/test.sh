
set -eu
BASEDIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
cd $BASEDIR



docker exec -ti s1     curl nginx
#docker exec -ti s1     curl http://nginx

#docker exec -ti client curl https://nginx
#docker exec -ti client curl https://registry.g1
