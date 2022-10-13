FROM alpine:3.16

RUN apk fix && \
    apk --no-cache --update add git git-lfs gpg less openssh && \
    git lfs install

COPY --from=zeetdev/cli:0.7.5  /usr/bin/zeet /usr/bin/zeet
