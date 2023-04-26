# Overview

Avalanche in docker compose. Patterned after eth-docker and meant to be used with https://github.com/CryptoManufaktur-io/base-docker-environment
for traefik and Prometheus.

`ext-network.yml` assumes a `traefik` network exists, where traefik and prometheus run

`cp default.env .env`, adjust variables, and `docker compose up -d`

There's an `rpc-shared.yml` if you want the RPC exposed locally, instead of via traefik

RCP sub-path is `/ext/bc/C/rpc`

WS sub-path is `/ext/bc/C/ws`

If you use a load balancer like  haproxy you can query `/ext/health` to see whether the node is bootstrapped
