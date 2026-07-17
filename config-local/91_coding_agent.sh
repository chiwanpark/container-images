#!/bin/bash
set -e

source "${HOME}/.nvm/nvm.sh"
nvm use default

# Run installers without a controlling terminal so interactive prompts select
# their default answers instead of blocking container startup.
noninteractive() {
  local url="$1"
  local interpreter="$2"
  local installer status=0
  shift 2

  installer=$(mktemp)
  if ! curl -fsSL "$url" -o "$installer"; then
    rm -f "$installer"
    return 1
  fi

  setsid --wait "$interpreter" "$installer" "$@" </dev/null || status=$?
  rm -f "$installer"
  return "$status"
}

noninteractive https://pi.dev/install.sh sh
CODEX_NON_INTERACTIVE=1 noninteractive https://chatgpt.com/codex/install.sh sh
noninteractive https://claude.ai/install.sh bash
noninteractive https://antigravity.google/cli/install.sh bash
npm install -g @getpaseo/cli
