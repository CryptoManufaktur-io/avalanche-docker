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

if [ -f "$HOME/.avalanchego/staking/signer.key" ]; then
  echo "Found Signer Key in keys folder"
else
  echo "Signer Key NOT found in keys folder - generating new one"
fi

if [ -f "$HOME/.avalanchego/staking/staker.key" ]; then
  echo "Found Staker Key in keys folder"
else
  echo "Staker Key NOT found in keys folder - generating new one"
fi


if [ -f "$HOME/.avalanchego/staking/staker.crt" ]; then
  echo "Found Staker CRT in keys folder"
else
  echo "Staker CRT NOT found in keys folder - generating new one"
fi
