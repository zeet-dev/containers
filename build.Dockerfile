FROM zeetdev/cli:0.7.4 as zeet-cli

FROM alpine:3.16

RUN apk fix && \
    apk --no-cache --update add git git-lfs gpg less openssh && \
    git lfs install

COPY --from=zeet-cli /usr/bin/zeet /usr/bin/zeet
