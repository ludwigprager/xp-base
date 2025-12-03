#!/usr/bin/env bash
set -eu

BASEDIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
cd $BASEDIR

source ../../../set-env.sh

CERT_DIR="${BASEDIR}/certs"
CA_DIR="${BASEDIR}/ca"

ROOT_CA_KEY=${CA_DIR}/private/ca.key
ROOT_CA_CERT=${CA_DIR}/certs/ca.crt

mkdir -p "${CERT_DIR}"
mkdir -p "${CA_DIR}"/{certs,crl,newcerts,private}
chmod 700 "${CA_DIR}/private"
touch "${CA_DIR}/index.txt"
echo 1000 > "${CA_DIR}/serial"

# -------------------------------------------------------------------
# Step 1: Create Root CA (only if not already present)
# -------------------------------------------------------------------
if [ ! -f "${ROOT_CA_KEY}" ]; then
  echo "🔑 Creating Root CA key..."
  openssl genrsa -out "${ROOT_CA_KEY}" 4096
  chmod 400 "${ROOT_CA_KEY}"

  echo "📜 Creating Root CA certificate..."
  openssl req -x509 -new -nodes \
    -key "${ROOT_CA_KEY}" \
    -sha256 -days 3650 \
    -out "${ROOT_CA_CERT}" \
    -subj "/C=DE/ST=Bayern/L=Kraiburg/O=XP-Base CA/CN=xp-base"
else
  echo "✅ Root CA already exists, skipping..."
fi

# -------------------------------------------------------------------
# Step 2: Create Server Certificate (matrix.g1 + element.g1)
# -------------------------------------------------------------------
SERVER_KEY="${CERT_DIR}/${REGISTRY_FQDN}.key"
SERVER_CSR="${CERT_DIR}/${REGISTRY_FQDN}.csr"
SERVER_CRT="${CERT_DIR}/${REGISTRY_FQDN}.crt"
SERVER_CONF="${CERT_DIR}/${REGISTRY_FQDN}.cnf"

cat > "${SERVER_CONF}" <<EOF
[ req ]
default_bits = 4096
prompt = no
default_md = sha256
req_extensions = req_ext
distinguished_name = dn

[dn]
C = DE
ST = Bayern
L = Kraiburg
O = Gschwendt1
CN = ${REGISTRY_FQDN}

[ req_ext ]
subjectAltName = @alt_names

[ alt_names ]
DNS.1 = ${REGISTRY_FQDN}
DNS.2 = secure.${REGISTRY_FQDN}
DNS.3 = quarantine.${REGISTRY_FQDN}
EOF

if [ ! -f "${SERVER_KEY}" ]; then
  echo "🔑 Creating server key..."
  openssl genrsa -out "${SERVER_KEY}" 4096
fi

if [ ! -f "${SERVER_CSR}" ]; then
  echo "📜 Creating CSR..."
  openssl req -new -key "${SERVER_KEY}" -out "${SERVER_CSR}" -config "${SERVER_CONF}"
fi

if [ ! -f "${SERVER_CRT}" ]; then
  echo "✅ Signing server certificate with Root CA..."
  openssl x509 -req -in "${SERVER_CSR}" \
    -CA "${ROOT_CA_CERT}" \
    -CAkey "${ROOT_CA_KEY}" \
    -CAcreateserial \
    -out "${SERVER_CRT}" \
    -days 825 -sha256 \
    -extfile "${SERVER_CONF}" -extensions req_ext
fi

##echo "🎉 Done!"
#echo "Root CA:            ${ROOT_CA_CERT}"
#echo "Server key:         ${SERVER_KEY}"
#echo "Server certificate: ${SERVER_CRT}"


## If still untrusted → ensure your server presents the full cert chain
## but since you’re self-signed, the single cert should be enough
FULLCHAIN=${CERT_DIR}/registry.g1.fullchain.crt
if [ ! -f "${FULLCHAIN}" ]; then
  echo creating full chain certificate
  cat $SERVER_CRT $ROOT_CA_CERT > $FULLCHAIN
fi

#echo "Full chain certificate: ${FULLCHAIN}"


