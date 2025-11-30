FROM docker:24-dind

RUN apk add --no-cache curl bash

ENV XP_VERSION=v2.1.1
RUN curl -sL "https://raw.githubusercontent.com/crossplane/crossplane/main/install.sh"
