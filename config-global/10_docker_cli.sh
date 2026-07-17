#!/bin/bash
set -e

DOCKER_GPG_URL="https://download.docker.com/linux/debian/gpg"
DOCKER_KEYRING="/etc/apt/keyrings/docker.asc"
DOCKER_SOURCE_LIST="/etc/apt/sources.list.d/docker.list"

if command -v docker > /dev/null 2>&1; then
  exit 0
fi

install -m 0755 -d /etc/apt/keyrings
curl -fsSL "${DOCKER_GPG_URL}" | tee "${DOCKER_KEYRING}" > /dev/null
chmod a+r "${DOCKER_KEYRING}"

ARCH="$(dpkg --print-architecture)"
CODENAME="$(
  . /etc/os-release
  echo "${VERSION_CODENAME}"
)"

echo "deb [arch=${ARCH} signed-by=${DOCKER_KEYRING}] https://download.docker.com/linux/debian ${CODENAME} stable" \
  | tee "${DOCKER_SOURCE_LIST}" > /dev/null

apt-get update
DEBIAN_FRONTEND=noninteractive apt-get install -y docker-ce-cli docker-buildx-plugin docker-compose-plugin

apt-get clean
rm -rf /var/lib/apt/lists/*
