#!/usr/bin/env bash
set -euo pipefail

VERSION="${VERSION:-24}"
GLOBALPACKAGES="${GLOBALPACKAGES-yarn pnpm neovim tree-sitter-cli}"
export DEBIAN_FRONTEND=noninteractive

if ! command -v curl >/dev/null 2>&1; then
  apt-get update
  apt-get install -y --no-install-recommends ca-certificates curl
fi

curl -fsSL "https://deb.nodesource.com/setup_${VERSION}.x" | bash -
apt-get install -y --no-install-recommends nodejs

if [ -n "${GLOBALPACKAGES}" ]; then
  read -ra packages <<< "${GLOBALPACKAGES}"
  npm install -g "${packages[@]}"
fi

npm cache clean --force
apt-get clean
rm -rf /var/lib/apt/lists/*
