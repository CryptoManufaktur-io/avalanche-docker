#!/usr/bin/env sh
set -eu

if [ ! -f /var/lib/ava/chain-configs/C/config.json ]; then
  mkdir -p /var/lib/ava/offline-pruning/
  mkdir -p /var/lib/ava/chain-configs/C/
  cp /root/config.json /var/lib/ava/chain-configs/C/
fi

cd /var/lib/ava/chain-configs/C/
if [ -f /var/lib/ava/prune-marker ]; then
  rm -f /var/lib/ava/prune-marker
  jq '.["offline-pruning-enabled"] = true' config.json > config.tmp && mv config.tmp config.json
else
  jq '.["offline-pruning-enabled"] = false' config.json > config.tmp && mv config.tmp config.json
fi
