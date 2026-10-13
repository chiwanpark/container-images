#!/usr/bin/env bash
set -euo pipefail

UVVERSION="${UVVERSION:-0.12.10}"
PYTHONVERSION="${PYTHONVERSION:-3.14}"
USERNAME="${_REMOTE_USER:-root}"
export DEBIAN_FRONTEND=noninteractive

if ! command -v curl >/dev/null 2>&1; then
  apt-get update
  apt-get install -y --no-install-recommends ca-certificates curl
  apt-get clean
  rm -rf /var/lib/apt/lists/*
fi

if [ "${UVVERSION}" = "latest" ]; then
  uv_installer_url="https://astral.sh/uv/install.sh"
else
  uv_installer_url="https://astral.sh/uv/${UVVERSION}/install.sh"
fi
curl -fsSL "${uv_installer_url}" | env UV_INSTALL_DIR=/usr/local/bin UV_NO_MODIFY_PATH=1 sh

su "${USERNAME}" -s /bin/bash -c "set -euo pipefail
uv python install '${PYTHONVERSION}'
uv tool install --python '${PYTHONVERSION}' 'python-lsp-server[all]'
uv cache clean"
