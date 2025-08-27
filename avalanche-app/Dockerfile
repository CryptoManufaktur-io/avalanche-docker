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
RUN mkdir -p /home/avalanche/.avalanchego/mainnet/pebble && \
    mkdir -p /home/avalanche/.avalanchego/staking && \
    chown -R ${USER}:${USER} /home/avalanche/.avalanchego && \
    chmod -R 700 /home/avalanche/.avalanchego

USER ${USER}
