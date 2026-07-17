#!/bin/bash
K9S_VERSION="0.51.0"
TMP_DIR=$(mktemp -d -t chiwan_XXXXXXXX)

if [[ ! -f "/usr/bin/kubectl" ]]; then
  curl -L -o ${TMP_DIR}/kubectl "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
  mv ${TMP_DIR}/kubectl /usr/bin/kubectl
  chmod +x /usr/bin/kubectl
  chown root:root /usr/bin/kubectl
fi

if [[ ! -f "/usr/bin/k9s" ]]; then
  curl -L -o ${TMP_DIR}/k9s_linux_amd64.deb https://github.com/derailed/k9s/releases/download/v${K9S_VERSION}/k9s_linux_amd64.deb
  dpkg -i ${TMP_DIR}/k9s_linux_amd64.deb
fi

rm -rf ${TMP_DIR}
