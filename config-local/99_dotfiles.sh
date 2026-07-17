#!/bin/bash
set -e 

SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
source ${HOME}/.venv/bin/activate

git clone https://github.com/chiwanpark/dotfiles.git ${HOME}/.dotfiles
cd ${HOME}/.dotfiles
./install.sh
