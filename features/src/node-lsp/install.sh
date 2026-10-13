#!/usr/bin/env bash
set -euo pipefail

TYPESCRIPT="${TYPESCRIPT:-true}"
SVELTE="${SVELTE:-true}"
TAILWIND="${TAILWIND:-true}"

if ! command -v npm >/dev/null 2>&1; then
  echo "node-lsp requires npm. Add the node feature first." >&2
  exit 1
fi

packages=()
if [ "${TYPESCRIPT}" = "true" ]; then
  packages+=(typescript typescript-language-server)
fi
if [ "${SVELTE}" = "true" ]; then
  packages+=(svelte-language-server)
fi
if [ "${TAILWIND}" = "true" ]; then
  packages+=(@tailwindcss/language-server)
fi

if [ "${#packages[@]}" -eq 0 ]; then
  echo "No language servers selected."
  exit 0
fi

npm install -g "${packages[@]}"
npm cache clean --force
