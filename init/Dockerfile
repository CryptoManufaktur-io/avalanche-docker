FROM alpine:latest

RUN apk update && apk add --no-cache jq wget
COPY set-prune.sh /usr/local/bin/
COPY config.json /root/

ENTRYPOINT [ "set-prune.sh" ]
