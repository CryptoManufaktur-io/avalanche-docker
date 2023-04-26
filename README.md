# Overview

Avalanche in docker compose. Patterned after eth-docker and meant to be used with https://github.com/CryptoManufaktur-io/base-docker-environment
for traefik and Prometheus.

`ext-network.yml` assumes a `traefik` network exists, where traefik and prometheus run

`cp default.env .env`, adjust variables, and `docker compose up -d`
