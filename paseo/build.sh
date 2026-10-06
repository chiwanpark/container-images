#!/bin/bash
set -euo pipefail

PKG_VERSION=6.23.0

if [ "$#" -ne 2 ]; then
  printf 'usage: %s <paseo-version> <output-file>\n' "$(basename "$0")" >&2
  exit 2
fi

paseo_version="$1"
output_file="$2"
source_dir=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
work_dir=$(mktemp -d)
build_dir="${work_dir}/oesap"
trap 'rm -rf "${work_dir}"' EXIT
export npm_config_cache="${work_dir}/npm-cache"
export PKG_CACHE_PATH="${work_dir}/pkg-cache"

mkdir -p "${build_dir}"
cp -a "${source_dir}/." "${build_dir}/"
cd "${build_dir}"

npm install --omit=dev --no-audit --no-fund "@getpaseo/cli@${paseo_version}"
node_major=$(node -p 'process.versions.node.split(".")[0]')
node_arch=$(node -p 'process.arch')

npx --yes "@yao-pkg/pkg@${PKG_VERSION}" . -t "node${node_major}-linux-${node_arch}" -o "${work_dir}/oesap.bin"

mkdir -p "$(dirname "${output_file}")"
install -m 0755 "${work_dir}/oesap.bin" "${output_file}.new"
mv -f "${output_file}.new" "${output_file}"
