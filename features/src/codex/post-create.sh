#!/usr/bin/env bash
set -euo pipefail

installer=$(mktemp)
trap 'rm -f "${installer}"' EXIT

curl -fsSL https://chatgpt.com/codex/install.sh -o "${installer}"
CODEX_NON_INTERACTIVE=1 setsid --wait sh "${installer}" </dev/null
