#!/bin/bash

set -eu
BASEDIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
cd $BASEDIR

 ./ssh-to-vm.sh docker exec  wireguard wg show

