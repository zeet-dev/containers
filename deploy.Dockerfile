FROM ubuntu:jammy
WORKDIR /app

RUN export DEBIAN_FRONTEND=noninteractive && apt-get update && \
    apt-get install -yqq apt-transport-https ca-certificates curl gettext git jq awscli gnupg2

RUN curl -fsSLo /usr/share/keyrings/kubernetes-archive-keyring.gpg https://packages.cloud.google.com/apt/doc/apt-key.gpg && \
    echo "deb [signed-by=/usr/share/keyrings/kubernetes-archive-keyring.gpg] https://apt.kubernetes.io/ kubernetes-xenial main" | tee /etc/apt/sources.list.d/kubernetes.list && \
    apt-get update && apt-get install -yqq kubectl=1.23.6-00

COPY --from=zeetdev/cli:0.7.5  /usr/bin/zeet /usr/bin/zeet
