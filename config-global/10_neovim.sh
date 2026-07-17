#!/bin/bash
NEOVIM_VERSION="0.12.4"
ARCHIVE_URL="https://github.com/neovim/neovim/releases/download/v${NEOVIM_VERSION}/nvim-linux-x86_64.tar.gz"
TMP_DIR=$(mktemp -d -t chiwan_XXXXXXXX)

if [[ ! -f "/usr/bin/nvim" ]]; then
  curl -fsSL -o ${TMP_DIR}/nvim-linux-x86_64.tar.gz ${ARCHIVE_URL}
  tar -xzf ${TMP_DIR}/nvim-linux-x86_64.tar.gz -C /opt
  ln -s /opt/nvim-linux-x86_64/bin/nvim /usr/bin/nvim
fi

rm -rf ${TMP_DIR}
