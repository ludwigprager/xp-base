#!/usr/bin/env bash

set -eu
BASEDIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
cd $BASEDIR

mkdir -p certs

# Generate a private key
openssl genrsa -out certs/server.key 2048

# Generate a self-signed certificate with SAN for 'nginx'
openssl req -x509 -new -nodes -key certs/server.key -sha256 -days 365 \
  -subj "/C=DE/ST=Bayern/L=Kraiburg/O=XP-Base/OU=IT/CN=xp-base" \
  -addext "subjectAltName = DNS:nginx" \
  -out certs/ca.crt


cp certs/ca.crt container/xpkg/
