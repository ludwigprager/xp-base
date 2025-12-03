FROM alpine:3.21

RUN apk add --no-cache curl bash ca-certificates openssl

ENV XP_VERSION=v2.1.1
RUN curl -sL "https://raw.githubusercontent.com/crossplane/crossplane/main/install.sh" | sh
RUN mv crossplane /usr/local/bin/

# Copy the FULLCHAIN (server + CA cert) instead of just CA
COPY registry.g1.fullchain.crt /usr/local/share/ca-certificates/registry-chain.crt

# Update certificates  
RUN update-ca-certificates && \
    echo "" >> /etc/ssl/certs/ca-certificates.crt && \
    cat /usr/local/share/ca-certificates/registry-chain.crt >> /etc/ssl/certs/ca-certificates.crt && \
    echo "=== Certificates in bundle ===" && \
    grep -c "BEGIN CERTIFICATE" /etc/ssl/certs/ca-certificates.crt

ENV CURL_CA_BUNDLE=/etc/ssl/certs/ca-certificates.crt
ENV SSL_CERT_FILE=/etc/ssl/certs/ca-certificates.crt

WORKDIR /work
