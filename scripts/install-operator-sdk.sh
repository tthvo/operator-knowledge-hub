#!/bin/bash
set -e

# Save current pwd
CURRENT_PWD=$(pwd)

print_message() {
  local MESSAGE=${1-""}
  echo "[INFO] ${MESSAGE}"
}

print_error() {
  local MESSAGE=${1-""}
  echo "[ERROR] ${MESSAGE}"
}

on_exit() {
  if [[ $? -eq 0 ]]; then 
    print_message "Done."
  else
    print_error "An error has occurred during installing operator-sdk"
  fi
  cd ${CURRENT_PWD}
}

exit_on_download_fail() {
  if [[ $1 -ne 200 ]]; then
    print_error "$2 not found"
    exit 1
  fi
}

trap on_exit EXIT

# Create a tmp dir if not yet
TMP_DIR="/tmp/test-operator-sdk"
[[ ! -d ${TMP_DIR} ]] && print_message "Creating ${TMP_DIR}" && mkdir -p ${TMP_DIR}
cd ${TMP_DIR}

# Set operator version
export OPERATOR_VERSION=${1-"1.22.1"}
print_message "Operator-sdk version: ${OPERATOR_VERSION}"


# Get OS information
export ARCH=$(case $(uname -m) in x86_64) echo -n amd64 ;; aarch64) echo -n arm64 ;; *) echo -n $(uname -m) ;; esac)
export OS=$(uname | awk '{print tolower($0)}')
print_message "Detected OS: ${OS}_${ARCH}"

# Set fetch URL for operator-sdk binary
export OPERATOR_SDK_DL_URL="https://github.com/operator-framework/operator-sdk/releases/download/v${OPERATOR_VERSION}"
print_message "Fetch URL: ${OPERATOR_SDK_DL_URL}"

# Fetch the binary
print_message "Downloading..."
DOWNLOAD_STATUS=$(curl -LO "${OPERATOR_SDK_DL_URL}/operator-sdk_${OS}_${ARCH}" -w "%{http_code}")
exit_on_download_fail $DOWNLOAD_STATUS "operator-sdk v${OPERATOR_VERSION}"
print_message "Sucessfully downloaded operator-sdk@${OPERATOR_VERSION} to ${TMP_DIR}/operator-sdk"

# Get release GPG key
print_message "Importing the operator-sdk release GPG key from keyserver.ubuntu.com"
gpg --keyserver keyserver.ubuntu.com --recv-keys 052996E2A20B5C7E

# Get checksum and signature
print_message "Downloading checksum file"
DOWNLOAD_STATUS=$(curl -LO ${OPERATOR_SDK_DL_URL}/checksums.txt -w "%{http_code}")
exit_on_download_fail $DOWNLOAD_STATUS "operator-sdk v${OPERATOR_VERSION} checksum"

print_message "Downloading signature"
DOWNLOAD_STATUS=$(curl -LO ${OPERATOR_SDK_DL_URL}/checksums.txt.asc -w "%{http_code}")
exit_on_download_fail $DOWNLOAD_STATUS "operator-sdk checksum v${OPERATOR_VERSION} signature"

# Verify signature
print_message "Verifying signature"
gpg -u "Operator SDK (release) <cncf-operator-sdk@cncf.io>" --verify checksums.txt.asc

# Verify checksum
print_message "Verifying checksum"
grep "operator-sdk_${OS}_${ARCH}" checksums.txt | sha256sum -c -

# Set executable bit to operator-sdk and add it to /usr/local/bin
sudo install -o root -g root -m 0755 operator-sdk_${OS}_${ARCH} /usr/local/bin/operator-sdk 
print_message "Installed operator-sdk to /usr/local/bin"

exit 0
