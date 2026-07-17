#!/bin/bash
set -e

# upgrade packages
apt-get update
apt-get upgrade -y

# timezone configuration
ln -sf /usr/share/zoneinfo/Asia/Seoul /etc/localtime
echo "Asia/Seoul" | tee /etc/timezone

# install base packages
DEBIAN_FRONTEND=noninteractive apt-get install -y \
  -o Dpkg::Options::="--force-confold" \
  -o Dpkg::Options::="--force-confdef" \
  curl tmux zsh git build-essential btop locales tzdata lsb-release cmake libomp-dev clangd \
  apt-transport-https ca-certificates debian-keyring fzf openssh-client sudo libbz2-dev \
  libsnappy-dev liblz4-dev zlib1g-dev libzstd-dev nginx gettext-base tree jq ripgrep fd-find gosu \
  tree-sitter-cli

# locale generation
locale-gen en_US.UTF-8

# cleanup
apt-get clean
rm -rf /var/lib/apt/lists/*
