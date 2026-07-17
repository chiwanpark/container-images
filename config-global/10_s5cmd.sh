#!/bin/bash
set -e

S5CMD_VERSION=2.3.0
ARTIFACT_URL="https://github.com/peak/s5cmd/releases/download/v${S5CMD_VERSION}/s5cmd_${S5CMD_VERSION}_linux_amd64.deb"

curl -fSL -o /tmp/s5cmd.deb ${ARTIFACT_URL}
dpkg -i /tmp/s5cmd.deb

rm -rf /tmp/s5cmd.deb
