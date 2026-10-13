#!/usr/bin/env bash
set -euo pipefail

export DEBIAN_FRONTEND=noninteractive

if ! command -v curl >/dev/null 2>&1; then
  apt-get update
  apt-get install -y --no-install-recommends ca-certificates curl
  apt-get clean
  rm -rf /var/lib/apt/lists/*
fi

install -d /usr/local/share/antigravity-feature
install -m 0755 "$(dirname "$0")/post-create.sh" /usr/local/share/antigravity-feature/post-create.sh
