#!/usr/bin/env bash
set -euo pipefail

export DEBIAN_FRONTEND=noninteractive

apt-get update
apt-get install -y --no-install-recommends cmake clangd libomp-dev
apt-get clean
rm -rf /var/lib/apt/lists/*
