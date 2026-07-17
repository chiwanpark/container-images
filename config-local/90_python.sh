#!/bin/bash
set -e

PYTHON_VERSION="3.14"
SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )

# install uv and Python
curl -LsSf https://astral.sh/uv/install.sh | sh
cd ${HOME}
source ${HOME}/.local/bin/env
uv venv --python ${PYTHON_VERSION}
source ${HOME}/.venv/bin/activate

# install Python tools
uv pip install "python-lsp-server[all]" neovim
