#!/usr/bin/env sh
set -eu

if [ ! -f /home/avalanche/.avalanchego/chain-configs/C/config.json ]; then
  mkdir -p /home/avalanche/.avalanchego/offline-pruning/
  mkdir -p /home/avalanche/.avalanchego/chain-configs/C/
  cp /home/avalanche/config.json /home/avalanche/.avalanchego/chain-configs/C/
fi

cd /home/avalanche/.avalanchego/chain-configs/C/
if [ -f /home/avalanche/.avalanchego/prune-marker ]; then
  rm -f /home/avalanche/.avalanchego/prune-marker
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
