#!/bin/bash
set -e

# Paseo self-updates by running `npm install -g`, so the global prefix must be
# user-writable. ~/.local keeps the binary on the existing PATH and persists it.
npm config set prefix "${HOME}/.local"
npm install -g @getpaseo/cli
