# Overview

Avalanche in Docker Compose.

Meant to be used with a [central traefik](https://github.com/CryptoManufaktur-io/central-proxy-docker)
for traefik and Prometheus.

`ext-network.yml` assumes a `traefik` network exists, where traefik and prometheus run

`./avad install` can install docker-ce for you

`cp default.env .env`, adjust variables, and `./avad up`

There's an `rpc-shared.yml` if you want the RPC exposed locally, instead of via traefik

RCP sub-path is `/ext/bc/C/rpc`

WS sub-path is `/ext/bc/C/ws`

If you use a load balancer like  haproxy you can query `/ext/health` to see whether the node is bootstrapped

To update Avalanche, use `./avad update` followed by `./avad up`

This is Avalanche Docker v1.3.1
