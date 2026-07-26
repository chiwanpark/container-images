#!/bin/bash
set -e

PYTHON_VERSION="3.14"
SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )

# install uv and Python
curl -LsSf https://astral.sh/uv/install.sh | sh
cd ${HOME}
source ${HOME}/.local/bin/env
uv python install ${PYTHON_VERSION}

# install Python tools
uv tool install "python-lsp-server[all]"
uv tool install huggingface_hub
