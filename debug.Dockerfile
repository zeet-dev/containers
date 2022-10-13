FROM golang:1.18 AS build_base

RUN export DEBIAN_FRONTEND=noninteractive && \
    apt-get update && apt-get install -yqq git unzip wget

# Set the Current Working Directory inside the container
WORKDIR /build

RUN curl https://releases.hashicorp.com/terraform/1.1.7/terraform_1.1.7_linux_amd64.zip -o terraform.zip
RUN unzip terraform.zip
RUN cp terraform /usr/local/bin/terraform

RUN curl -fsSL -o get_helm.sh https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3
RUN chmod +x get_helm.sh
RUN ./get_helm.sh

RUN wget https://github.com/roboll/helmfile/archive/refs/tags/v0.142.0.tar.gz
RUN tar -xzvf v0.142.0.tar.gz
RUN cd helmfile-0.142.0 && make build
RUN cp helmfile-0.142.0/helmfile /usr/local/bin/helmfile

# Start fresh from a smaller image
FROM ubuntu:jammy
WORKDIR /app

RUN export DEBIAN_FRONTEND=noninteractive && apt-get update && \
    apt-get install -yqq apt-transport-https ca-certificates curl python3 gettext git jq awscli gnupg2

RUN curl -fsSLo /usr/share/keyrings/kubernetes-archive-keyring.gpg https://packages.cloud.google.com/apt/doc/apt-key.gpg && \
    echo "deb [signed-by=/usr/share/keyrings/kubernetes-archive-keyring.gpg] https://apt.kubernetes.io/ kubernetes-xenial main" | tee /etc/apt/sources.list.d/kubernetes.list && \
    apt-get update && apt-get install -yqq kubectl=1.23.6-00

RUN curl https://packages.cloud.google.com/apt/doc/apt-key.gpg | tee /usr/share/keyrings/cloud.google.gpg && \
    echo "deb [signed-by=/usr/share/keyrings/cloud.google.gpg] https://packages.cloud.google.com/apt cloud-sdk main" | tee -a /etc/apt/sources.list.d/google-cloud-sdk.list && \
    apt-get update && apt-get install google-cloud-cli

RUN curl -o aws-iam-authenticator https://amazon-eks.s3.us-west-2.amazonaws.com/1.21.2/2021-07-05/bin/linux/amd64/aws-iam-authenticator && \
    chmod +x ./aws-iam-authenticator && \
    mv ./aws-iam-authenticator /usr/local/bin/aws-iam-authenticator

COPY --from=zeetdev/cli:0.7.5  /usr/bin/zeet /usr/bin/zeet
COPY --from=build_base /usr/local/bin/terraform /usr/local/bin/
COPY --from=build_base /usr/local/bin/helm /usr/local/bin/
COPY --from=build_base /usr/local/bin/helmfile /usr/local/bin/
RUN helm plugin install https://github.com/databus23/helm-diff
