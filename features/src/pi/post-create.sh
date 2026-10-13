#!/usr/bin/env bash
set -euo pipefail

installer=$(mktemp)
trap 'rm -f "${installer}"' EXIT

curl -fsSL https://pi.dev/install.sh -o "${installer}"
setsid --wait sh "${installer}" </dev/null

mkdir -p "$HOME/.local/bin"
ln -sfn "$HOME/.pi/agent/bin/pi" "$HOME/.local/bin/pi"
