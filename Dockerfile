ARG UV_VERSION=0.12.10
FROM ghcr.io/astral-sh/uv:${UV_VERSION} AS uv

FROM debian:13

LABEL maintainer="Chiwan Park <chiwanpark@hotmail.com>"

USER root

ARG DEBIAN_FRONTEND=noninteractive
ARG TARGETARCH

# base packages
RUN apt-get update \
 && ln -sf /usr/share/zoneinfo/Asia/Seoul /etc/localtime \
 && echo "Asia/Seoul" > /etc/timezone \
 && apt-get install -y \
      -o Dpkg::Options::="--force-confold" \
      -o Dpkg::Options::="--force-confdef" \
      --no-install-recommends \
      curl tmux zsh git build-essential btop locales tzdata lsb-release cmake libomp-dev clangd \
      apt-transport-https ca-certificates debian-keyring fzf openssh-client sudo libbz2-dev \
      libsnappy-dev liblz4-dev zlib1g-dev libzstd-dev nginx gettext-base tree jq ripgrep fd-find gosu \
      procps python3 python3-pynvim rocm-smi rocminfo unzip zip \
 && sed -i 's/^# *en_US.UTF-8 UTF-8/en_US.UTF-8 UTF-8/' /etc/locale.gen \
 && locale-gen \
 && apt-get clean \
 && rm -rf /var/lib/apt/lists/*

# docker cli
RUN install -m 0755 -d /etc/apt/keyrings \
 && curl -fsSL -o /etc/apt/keyrings/docker.asc https://download.docker.com/linux/debian/gpg \
 && chmod a+r /etc/apt/keyrings/docker.asc \
 && echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/debian $(. /etc/os-release && echo ${VERSION_CODENAME}) stable" \
      > /etc/apt/sources.list.d/docker.list \
 && apt-get update \
 && apt-get install -y --no-install-recommends docker-ce-cli docker-buildx-plugin docker-compose-plugin \
 && apt-get clean \
 && rm -rf /var/lib/apt/lists/*

# github cli
RUN install -m 0755 -d /etc/apt/keyrings \
 && curl -fsSL -o /etc/apt/keyrings/githubcli-archive-keyring.gpg https://cli.github.com/packages/githubcli-archive-keyring.gpg \
 && chmod a+r /etc/apt/keyrings/githubcli-archive-keyring.gpg \
 && echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" \
      > /etc/apt/sources.list.d/github-cli.list \
 && apt-get update \
 && apt-get install -y --no-install-recommends gh \
 && apt-get clean \
 && rm -rf /var/lib/apt/lists/*

# node.js
ARG NODE_VERSION=24
RUN curl -fsSL https://deb.nodesource.com/setup_${NODE_VERSION}.x | bash - \
 && apt-get install -y --no-install-recommends nodejs \
 && npm install -g yarn pnpm neovim tree-sitter-cli \
      typescript-language-server typescript svelte-language-server @tailwindcss/language-server \
 && npm cache clean --force \
 && apt-get clean \
 && rm -rf /var/lib/apt/lists/*

# paseo
RUN npm install -g @getpaseo/cli \
 && npm cache clean --force

# agent-browser
ARG AGENT_BROWSER_VERSION=0.37.0
RUN npm install -g "agent-browser@${AGENT_BROWSER_VERSION}" \
 && mkdir -p /opt/agent-browser \
 && HOME=/opt/agent-browser agent-browser install --with-deps \
 && mv /opt/agent-browser/.agent-browser/browsers /opt/agent-browser/browsers \
 && rm -rf /opt/agent-browser/.agent-browser \
 && chmod -R a+rX /opt/agent-browser \
 && npm cache clean --force \
 && apt-get clean \
 && rm -rf /var/lib/apt/lists/*

# uv
COPY --from=uv /uv /uvx /usr/local/bin/

# aws cli and sam cli
ARG AWS_CLI_VERSION=2.36.40
ARG SAM_CLI_VERSION=1.166.1
RUN case "${TARGETARCH}" in \
      amd64) aws_arch="x86_64"; sam_arch="x86_64" ;; \
      arm64) aws_arch="aarch64"; sam_arch="arm64" ;; \
      *) echo "unsupported architecture: ${TARGETARCH}" >&2 && exit 1 ;; \
    esac \
 && curl -fsSL -o /tmp/awscliv2.zip "https://awscli.amazonaws.com/awscli-exe-linux-${aws_arch}-${AWS_CLI_VERSION}.zip" \
 && unzip -q /tmp/awscliv2.zip -d /tmp \
 && /tmp/aws/install \
 && curl -fsSL -o /tmp/aws-sam-cli.zip "https://github.com/aws/aws-sam-cli/releases/download/v${SAM_CLI_VERSION}/aws-sam-cli-linux-${sam_arch}.zip" \
 && unzip -q /tmp/aws-sam-cli.zip -d /tmp/sam-installation \
 && /tmp/sam-installation/install \
 && rm -rf /tmp/awscliv2.zip /tmp/aws /tmp/aws-sam-cli.zip /tmp/sam-installation

# golang
ARG GO_VERSION=1.26.5
RUN curl -fsSL -o /tmp/go.tar.gz "https://go.dev/dl/go${GO_VERSION}.linux-${TARGETARCH}.tar.gz" \
 && tar -C /usr/local -xzf /tmp/go.tar.gz \
 && rm -f /tmp/go.tar.gz
ENV PATH="/usr/local/go/bin:${PATH}"

# s5cmd
ARG S5CMD_VERSION=2.3.0
RUN curl -fsSL -o /tmp/s5cmd.deb "https://github.com/peak/s5cmd/releases/download/v${S5CMD_VERSION}/s5cmd_${S5CMD_VERSION}_linux_${TARGETARCH}.deb" \
 && dpkg -i /tmp/s5cmd.deb \
 && rm -f /tmp/s5cmd.deb

# kubectl and k9s
ARG KUBECTL_VERSION=1.37.0
ARG K9S_VERSION=0.51.0
RUN curl -fsSL -o /usr/bin/kubectl "https://dl.k8s.io/release/v${KUBECTL_VERSION}/bin/linux/${TARGETARCH}/kubectl" \
 && chown root:root /usr/bin/kubectl \
 && chmod 0755 /usr/bin/kubectl \
 && curl -fsSL -o /tmp/k9s.deb "https://github.com/derailed/k9s/releases/download/v${K9S_VERSION}/k9s_linux_${TARGETARCH}.deb" \
 && dpkg -i /tmp/k9s.deb \
 && rm -f /tmp/k9s.deb

# neovim
ARG NEOVIM_VERSION=0.12.4
RUN case "${TARGETARCH}" in \
      amd64) nvim_arch="x86_64" ;; \
      arm64) nvim_arch="arm64" ;; \
      *) echo "unsupported architecture: ${TARGETARCH}" >&2 && exit 1 ;; \
    esac \
 && curl -fsSL -o /tmp/nvim.tar.gz "https://github.com/neovim/neovim/releases/download/v${NEOVIM_VERSION}/nvim-linux-${nvim_arch}.tar.gz" \
 && tar -xzf /tmp/nvim.tar.gz -C /opt \
 && ln -s "/opt/nvim-linux-${nvim_arch}/bin/nvim" /usr/bin/nvim \
 && rm -f /tmp/nvim.tar.gz

# user configuration
COPY ./config-local/ /etc/config-local/

# utility commands
COPY --chmod=0755 ./bin/kill-zombies /usr/local/bin/kill-zombies

# entrypoint
COPY --chmod=0755 entrypoint.sh /usr/bin/entrypoint.sh
ENTRYPOINT ["/usr/bin/entrypoint.sh"]
CMD ["/bin/zsh", "-ic", "exec paseo daemon start --foreground"]
