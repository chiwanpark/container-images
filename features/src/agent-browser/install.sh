#!/usr/bin/env bash
set -euo pipefail

VERSION="${VERSION:-0.39.0}"
INSTALL_DIR=/opt/agent-browser
export DEBIAN_FRONTEND=noninteractive

if ! command -v npm >/dev/null 2>&1; then
  echo "agent-browser requires npm. Add the node feature first." >&2
  exit 1
fi

npm install -g "agent-browser@${VERSION}"

rm -rf "${INSTALL_DIR}"
mkdir -p "${INSTALL_DIR}"
HOME="${INSTALL_DIR}" agent-browser install --with-deps
mv "${INSTALL_DIR}/.agent-browser/browsers" "${INSTALL_DIR}/browsers"
rm -rf "${INSTALL_DIR}/.agent-browser"

chrome_dir=$(find "${INSTALL_DIR}/browsers" -mindepth 1 -maxdepth 1 -type d -name 'chrome-*' | sort -V | tail -n 1)
if [ -z "${chrome_dir}" ] || [ ! -x "${chrome_dir}/chrome" ]; then
  echo "Chrome executable not found in ${INSTALL_DIR}/browsers" >&2
  exit 1
fi
ln -sfn "${chrome_dir}" "${INSTALL_DIR}/chrome"
chmod -R a+rX "${INSTALL_DIR}"

npm cache clean --force
apt-get clean
rm -rf /var/lib/apt/lists/*
