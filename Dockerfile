FROM debian:13

LABEL maintainer="Chiwan Park <chiwanpark@hotmail.com>"

ARG DEBIAN_FRONTEND=noninteractive
ARG TARGETARCH

RUN apt-get update \
 && apt-get install -y --no-install-recommends \
      ca-certificates curl git sudo locales tmux openssh-client less unzip zip gzip \
      jq ripgrep fd-find fzf tree btop build-essential \
      libbz2-dev libsnappy-dev liblz4-dev zlib1g-dev libzstd-dev \
 && sed -i 's/^# *en_US.UTF-8 UTF-8/en_US.UTF-8 UTF-8/' /etc/locale.gen \
 && locale-gen \
 && install -m 0755 -d /etc/apt/keyrings \
 && curl -fsSL -o /etc/apt/keyrings/docker.asc https://download.docker.com/linux/debian/gpg \
 && curl -fsSL -o /etc/apt/keyrings/githubcli-archive-keyring.gpg https://cli.github.com/packages/githubcli-archive-keyring.gpg \
 && chmod a+r /etc/apt/keyrings/docker.asc /etc/apt/keyrings/githubcli-archive-keyring.gpg \
 && echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/debian $(. /etc/os-release && echo ${VERSION_CODENAME}) stable" \
      > /etc/apt/sources.list.d/docker.list \
 && echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" \
      > /etc/apt/sources.list.d/github-cli.list \
 && apt-get update \
 && apt-get install -y --no-install-recommends docker-ce-cli docker-buildx-plugin docker-compose-plugin gh \
 && apt-get clean \
 && rm -rf /var/lib/apt/lists/*

ENV LANG=en_US.UTF-8 \
    LC_ALL=en_US.UTF-8

ARG S5CMD_VERSION=2.3.0
ARG KUBECTL_VERSION=1.37.0
ARG K9S_VERSION=0.51.0
RUN curl -fsSL -o /tmp/s5cmd.deb "https://github.com/peak/s5cmd/releases/download/v${S5CMD_VERSION}/s5cmd_${S5CMD_VERSION}_linux_${TARGETARCH}.deb" \
 && curl -fsSL -o /tmp/k9s.deb "https://github.com/derailed/k9s/releases/download/v${K9S_VERSION}/k9s_linux_${TARGETARCH}.deb" \
 && dpkg -i /tmp/s5cmd.deb /tmp/k9s.deb \
 && rm -f /tmp/s5cmd.deb /tmp/k9s.deb \
 && curl -fsSL -o /usr/local/bin/kubectl "https://dl.k8s.io/release/v${KUBECTL_VERSION}/bin/linux/${TARGETARCH}/kubectl" \
 && chmod 0755 /usr/local/bin/kubectl

ARG NEOVIM_VERSION=0.12.6
RUN case "${TARGETARCH}" in \
      amd64) nvim_arch="x86_64" ;; \
      arm64) nvim_arch="arm64" ;; \
      *) echo "unsupported architecture: ${TARGETARCH}" >&2 && exit 1 ;; \
    esac \
 && curl -fsSL -o /tmp/nvim.tar.gz "https://github.com/neovim/neovim/releases/download/v${NEOVIM_VERSION}/nvim-linux-${nvim_arch}.tar.gz" \
 && tar -xzf /tmp/nvim.tar.gz -C /opt \
 && ln -s "/opt/nvim-linux-${nvim_arch}/bin/nvim" /usr/local/bin/nvim \
 && rm -f /tmp/nvim.tar.gz
