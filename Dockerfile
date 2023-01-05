FROM alpine:3.16.2

RUN apk update && apk add git openssh-client; \
    apk add --no-cache curl=7.83.1-r5 bash=5.1.16-r2 git=2.36.3-r0 py3-pip=22.1.1-r0 moreutils=0.67-r0

RUN pip install 'yq==2.10.0'

RUN curl -LO https://github.com/stedolan/jq/releases/download/jq-1.6/jq-linux64 && \
    chmod +x ./jq-linux64 && \
    mv ./jq-linux64 /usr/bin/jq

COPY entrypoint.sh /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]
