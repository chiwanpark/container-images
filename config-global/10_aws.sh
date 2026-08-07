#!/bin/bash
set -e

AWS_CLI_URL="https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip"
SAM_CLI_URL="https://github.com/aws/aws-sam-cli/releases/latest/download/aws-sam-cli-linux-x86_64.zip"
TMP_DIR=$(mktemp -d -t chiwan_XXXXXXXX)

if ! command -v aws > /dev/null 2>&1; then
  curl -fsSL -o "${TMP_DIR}/awscliv2.zip" "${AWS_CLI_URL}"
  unzip -q "${TMP_DIR}/awscliv2.zip" -d "${TMP_DIR}"
  "${TMP_DIR}/aws/install"
fi

if ! command -v sam > /dev/null 2>&1; then
  curl -fsSL -o "${TMP_DIR}/aws-sam-cli.zip" "${SAM_CLI_URL}"
  unzip -q "${TMP_DIR}/aws-sam-cli.zip" -d "${TMP_DIR}/sam-installation"
  "${TMP_DIR}/sam-installation/install"
fi

rm -rf "${TMP_DIR}"
