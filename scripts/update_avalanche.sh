#!/usr/bin/env bash
set -euo pipefail

log(){ echo "==> $*"; }
warn(){ echo "WARN: $*" >&2; }
die(){ echo "ERROR: $*" >&2; exit 1; }

prompt() {
  local msg="$1" var=""
  read -r -p "$msg" var
  echo "$var"
}

is_docker_available() { command -v docker >/dev/null 2>&1; }

container_exists() {
  local cname="${1:-}"
  [[ -n "$cname" ]] || return 1
  is_docker_available || return 1
  docker ps -a --format '{{.Names}}' | grep -Fxq -- "$cname"
}

get_version_from_container() {
  local cname="${1:-}"
  container_exists "$cname" || { echo ""; return 0; }

  local out ver
  out="$(docker exec "$cname" sh -lc \
    '/avalanchego/build/avalanchego --version 2>/dev/null || avalanchego --version 2>/dev/null || true' \
    2>/dev/null || true)"

  # Prefer avalanchego/<version> (e.g. avalanchego/1.14.1) to avoid picking database=vX.Y.Z
  ver="$(echo "$out" | grep -Eo 'avalanchego/[0-9]+\.[0-9]+\.[0-9]+' | head -n1 | cut -d/ -f2 || true)"

  # Fallback: if output is different on some builds, try "avalanchego version vX.Y.Z"
  if [[ -z "$ver" ]]; then
    ver="$(echo "$out" | grep -Eo 'v[0-9]+\.[0-9]+\.[0-9]+' | head -n1 | sed 's/^v//' || true)"
  fi

  echo "${ver:-}"
}

check_dir() {
  local dir="$1"
  [[ -d "$dir" ]] || die "Directory not found: $dir"
  [[ -x "$dir/ethd" ]] || die "ethd not found or not executable: $dir/ethd"
  [[ -d "$dir/keys-unstaked" ]] || die "Missing directory: $dir/keys-unstaked"
}

# Read 'keys' symlink target and normalize by removing trailing slashes.
# Returns "" if keys is missing or not a symlink.
read_keys_link_normalized() {
  local dir="$1"
  [[ -L "$dir/keys" ]] || { echo ""; return 0; }

  local raw
  raw="$(readlink "$dir/keys" 2>/dev/null || true)"
  # Normalize: remove trailing slashes like keys-unstaked/ -> keys-unstaked
  raw="$(printf '%s' "$raw" | sed 's:/*$::')"
  echo "${raw:-}"
}

ensure_keys_points_to_unstaked() {
  local dir="$1"

  # If keys exists but is not a symlink, fail safely
  if [[ -e "$dir/keys" && ! -L "$dir/keys" ]]; then
    die "'$dir/keys' exists but is not a symlink. Refusing to modify."
  fi

  local link
  link="$(read_keys_link_normalized "$dir")"

  if [[ -z "$link" ]]; then
    log "keys symlink missing -> creating keys -> keys-unstaked"
    ln -s keys-unstaked "$dir/keys"
    return 0
  fi

  log "keys currently -> $link"

  if [[ "$link" == "keys-unstaked" ]]; then
    log "keys already points to keys-unstaked; skipping."
    return 0
  fi

  if [[ "$link" == "keys-staked" ]]; then
    log "keys points to keys-staked -> switching to keys-unstaked"
    rm -f "$dir/keys"
    ln -s keys-unstaked "$dir/keys"
    return 0
  fi

  die "keys symlink points to unexpected target: '$link' (expected keys-staked or keys-unstaked)"
}


run_ethd() {
  local dir="$1" cmd="$2"
  log "Running: ./ethd $cmd"
  (cd "$dir" && ./ethd "$cmd")
}

main() {
  local dir target cname current

  dir="$(prompt "Avalanche directory path (contains ./ethd, keys, keys-unstaked): ")"
  [[ -n "$dir" ]] || die "No directory provided"
  check_dir "$dir"

  target="$(prompt "Target avalanchego version (e.g. v1.12.3): ")"
  [[ -n "$target" ]] || die "No target version provided"

  cname="$(prompt "Docker container name for version check (optional, Enter to skip): ")"

  if [[ -n "$cname" ]] && container_exists "$cname"; then
    current="$(get_version_from_container "$cname")"
    if [[ -n "$current" ]]; then
      log "Detected running avalanchego version ($cname): $current"
      if [[ "$current" == "$target" ]]; then
        log "Already at target version ($target). Skipping upgrade."
        exit 0
      fi
    else
      warn "Could not detect avalanchego version from container '$cname' (continuing)."
    fi
  else
    [[ -n "$cname" ]] && warn "Container '$cname' not found or docker unavailable; skipping version check."
  fi

  run_ethd "$dir" update
  run_ethd "$dir" down
  ensure_keys_points_to_unstaked "$dir"
  run_ethd "$dir" up

  if [[ -n "$cname" ]] && container_exists "$cname"; then
    current="$(get_version_from_container "$cname")"
    [[ -n "$current" ]] && log "Post-upgrade version ($cname): $current"
  fi

  log "✅ Done."
}

main "$@"