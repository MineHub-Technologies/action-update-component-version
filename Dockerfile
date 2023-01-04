FROM alpine:3.16.2

RUN apk update && apk add git openssh-client; \
    apk add --no-cache bash=5.1.16-r2 git=2.36.3-r0

COPY entrypoint.sh /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]
