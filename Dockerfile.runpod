FROM nvcr.io/nvidia/cuda:12.8.1-cudnn-devel-ubuntu24.04

LABEL maintainer="Chiwan Park <chiwanpark@hotmail.com>"

USER root

RUN apt-get update \
 && apt-get upgrade -y \
 && apt-get install -y --no-install-recommends \
        build-essential ca-certificates curl git libnuma-dev libopenmpi-dev zsh tmux htop openssh-server \
 && rm -rf /var/lib/apt/lists/* \
 && apt-get clean

COPY --from=ghcr.io/astral-sh/uv:latest /uv /uvx /bin/

RUN uv venv -p python3.12 /root/.venv
ENV VIRTUAL_ENV=/root/.venv
ENV PATH="${VIRTUAL_ENV}/bin:${PATH}"
RUN uv pip install tensorboard supervisor jupyterlab "huggingface-hub[cli]" "python-lsp-server[all]" neovim

RUN curl -LO https://github.com/neovim/neovim/releases/latest/download/nvim-linux-x86_64.tar.gz \
 && tar -C /opt -xzf nvim-linux-x86_64.tar.gz \
 && rm -rf nvim-linux-x86_64.tar.gz \
 && ln -s /opt/nvim-linux-x86_64/bin/nvim /usr/bin/nvim

RUN curl -LO https://github.com/tsl0922/ttyd/releases/download/1.7.7/ttyd.x86_64 \
 && mv ttyd.x86_64 /bin/ttyd \
 && chmod +x /bin/ttyd

RUN git clone https://github.com/chiwanpark/dotfiles.git /root/.dotfiles \
 && bash /root/.dotfiles/install.sh

RUN git config --global user.name "Chiwan Park" \
 && git config --global user.email "chiwanpark@hotmail.com"

ENV HF_HOME=/workspace/hf-cache

# add resources
ADD res/sshd_config /etc/ssh/sshd_config
ADD res/jupyter_lab_config.py /root/.jupyter/jupyter_lab_config.py
ADD res/supervisord.conf /etc/supervisord.conf
ADD res/entrypoint.sh /sbin/entrypoint.sh

RUN chsh -s /bin/zsh
WORKDIR /workspace
ENTRYPOINT ["/sbin/entrypoint.sh"]
