#!/bin/bash
set -e

GO_VERSION=1.26.5
GO_ARCHIVE_NAME=go${GO_VERSION}.linux-amd64.tar.gz
GO_URL=https://go.dev/dl/${GO_ARCHIVE_NAME}

if command -v go > /dev/null 2>&1; then
  exit 0
fi

curl -fL -o /tmp/${GO_ARCHIVE_NAME} ${GO_URL}
tar -C /usr/local -xzf /tmp/${GO_ARCHIVE_NAME}
rm -rf /tmp/${GO_ARCHIVE_NAME}
