#!/usr/bin/env bash
set -euo pipefail

VERSION="${VERSION:-0.7.4}"
USERNAME="${_REMOTE_USER:-root}"

if ! command -v uv >/dev/null 2>&1; then
  echo "google-colab-cli requires uv. Add the python feature first." >&2
  exit 1
fi

if [ "${VERSION}" = "latest" ]; then
  package="google-colab-cli"
else
  package="google-colab-cli==${VERSION}"
fi

su "${USERNAME}" -s /bin/bash -c "set -euo pipefail
uv tool install '${package}'
uv cache clean"
