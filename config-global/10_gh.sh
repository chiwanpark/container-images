#!/bin/bash
set -e

GH_KEYRING_URL="https://cli.github.com/packages/githubcli-archive-keyring.gpg"
GH_KEYRING="/etc/apt/keyrings/githubcli-archive-keyring.gpg"
GH_SOURCE_LIST="/etc/apt/sources.list.d/github-cli.list"

if command -v gh > /dev/null 2>&1; then
  exit 0
fi

install -m 0755 -d /etc/apt/keyrings
curl -fsSL "${GH_KEYRING_URL}" -o "${GH_KEYRING}"
chmod a+r "${GH_KEYRING}"

echo "deb [arch=$(dpkg --print-architecture) signed-by=${GH_KEYRING}] https://cli.github.com/packages stable main" \
  | tee "${GH_SOURCE_LIST}" > /dev/null

apt-get update
DEBIAN_FRONTEND=noninteractive apt-get install -y gh

apt-get clean
rm -rf /var/lib/apt/lists/*
