ARG DAEMON_VERSION=latest
FROM avaplatform/avalanchego:${DAEMON_VERSION}

ARG USER=avalanche
ARG UID=10001

# See https://stackoverflow.com/a/55757473/12429735RUN
RUN adduser \
    --disabled-password \
    --gecos "" \
    --shell "/sbin/nologin" \
    --uid "${UID}" \
    "${USER}"

RUN usermod -rG users ${USER}

# Create directory and fix ownership
RUN mkdir -p /var/lib/ava/mainnet/pebble && \
    chown -R ${USER}:${USER} /var/lib/ava && \
    chmod -R 700 /var/lib/ava

USER ${USER}
