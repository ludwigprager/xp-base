set -eu
BASEDIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
cd $BASEDIR

./generate-certs.sh
./up.sh

./test.sh

./down.sh
