# container-images

Personalized dev container environments for Chiwan Park.

## Base image

`ghcr.io/chiwanpark/container-images` is a minimal Debian 13 image with git, gh, curl, sudo, locales (en_US.UTF-8), tmux, openssh-client, less, zip/unzip, jq, ripgrep, fd-find, fzf, tree, btop, build-essential, compression libraries, Neovim, Docker CLI, kubectl, k9s, and s5cmd.

It has no user or entrypoint; use it through the [Dev Container spec](https://containers.dev).

## Features

Features are published to `ghcr.io/chiwanpark/container-images/<feature>`.

| Feature | Description |
|---|---|
| `node` | Node.js from NodeSource with yarn, pnpm, neovim, and tree-sitter-cli |
| `node-lsp` | Language servers for TypeScript/JavaScript (including React), Svelte, and Tailwind CSS (requires `node`) |
| `agent-browser` | agent-browser with a bundled Chrome (requires `node`) |
| `python` | uv, a uv-managed Python, and python-lsp-server |
| `google-colab-cli` | google-colab-cli installed with uv (requires `python`) |
| `pi` | pi, installed on container creation (requires `node`) |
| `codex` | Codex CLI, installed on container creation |
| `claude` | Claude Code, installed on container creation |
| `antigravity` | Antigravity CLI, installed on container creation |
| `rocm` | rocm-smi and rocminfo; adds the remote user to the groups owning `/dev/kfd` and `/dev/dri/*` |
| `cpp-tools` | CMake, clangd, and OpenMP development files |

Use official features for the rest, e.g. `common-utils` (user, zsh), `docker-outside-of-docker`, and `aws-cli`.

## Usage

Reference the image and features from a `devcontainer.json`:

```json
{
  "image": "ghcr.io/chiwanpark/container-images:latest",
  "features": {
    "ghcr.io/devcontainers/features/common-utils:2": { "username": "chiwanpark", "configureZshAsDefaultShell": true },
    "ghcr.io/chiwanpark/container-images/node:1": {},
    "ghcr.io/chiwanpark/container-images/python:1": {}
  },
  "remoteUser": "chiwanpark"
}
```

Start it with dotfiles:

```sh
devcontainer up --workspace-folder . \
  --dotfiles-repository https://github.com/chiwanpark/dotfiles \
  --dotfiles-target-path '~/.dotfiles' \
  --dotfiles-install-command install.sh
```

To use AMD GPUs with the `rocm` feature, pass the devices:

```json
"runArgs": ["--device=/dev/kfd", "--device=/dev/dri"]
```

## Development

This repository's own dev container is defined in [.devcontainer/devcontainer.json](.devcontainer/devcontainer.json) and includes Docker access, the devcontainer CLI, and coding agents.
