#FROM docker:24-dind
FROM alpine:3.21

RUN apk add --no-cache curl bash ca-certificates

ENV XP_VERSION=v2.1.1
RUN curl -sL "https://raw.githubusercontent.com/crossplane/crossplane/main/install.sh" | sh
RUN mv crossplane /usr/local/bin/

COPY myCA.crt /usr/local/share/ca-certificates/ca.crt
RUN update-ca-certificates

# Set working directory
WORKDIR /work

# Keep container open for interactive use
#CMD ["sh"]
