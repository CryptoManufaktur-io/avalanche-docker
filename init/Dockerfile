FROM alpine:latest

ARG USER=avalanche
ARG UID=10001

RUN apk update && apk add --no-cache jq wget
COPY set-prune.sh /usr/local/bin/
COPY config.json /home/avalanche

# See https://stackoverflow.com/a/55757473/12429735RUN
RUN adduser \
    --disabled-password \
    --gecos "" \
    --shell "/sbin/nologin" \
    --uid "${UID}" \
    "${USER}"

USER ${USER}

ENTRYPOINT [ "set-prune.sh" ]
