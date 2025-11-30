
FROM docker:24-dind
# Add tools or config here

RUN apk add --no-cache curl bash

ENV XP_VERSION=v2.1.1
RUN curl -sL "https://raw.githubusercontent.com/crossplane/crossplane/main/install.sh"
#RUN chmod +x crossplane
#RUN mv crossplane /usr/local/bin/
#RUN /usr/local/bin/crossplane version

