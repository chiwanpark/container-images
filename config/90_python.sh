#!/bin/bash
set -e

PYTHON_VERSION="3.14"

# install Python
uv python install ${PYTHON_VERSION}

# install Python tools
uv tool install "python-lsp-server[all]"
uv tool install huggingface_hub
