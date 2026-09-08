#!/bin/bash
set -e

PYTHON_VERSION="3.14"
GOOGLE_COLAB_CLI_URL="https://github.com/googlecolab/google-colab-cli.git"
GOOGLE_COLAB_CLI_COMMIT="465b941001afa3d804fa2094bed763236b72e654"

# install Python
uv python install ${PYTHON_VERSION}

# install Python tools
uv tool install "python-lsp-server[all]"
uv tool install huggingface_hub
uv tool install --with "jupyter-kernel-client<1" \
  "google-colab-cli @ git+${GOOGLE_COLAB_CLI_URL}@${GOOGLE_COLAB_CLI_COMMIT}"
