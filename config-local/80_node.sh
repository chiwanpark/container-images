#!/bin/bash
set -e

NVM_VERSION="0.40.5"
NODE_VERSION="24"

# install nvm and Node.js
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v${NVM_VERSION}/install.sh | bash
source ${HOME}/.nvm/nvm.sh
nvm install ${NODE_VERSION}
nvm use ${NODE_VERSION} --default

# node.js environment
npm install -g yarn pnpm neovim tree-sitter-cli \
  typescript-language-server typescript svelte-language-server @tailwindcss/language-server
