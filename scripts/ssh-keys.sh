#!/usr/bin/env bash

set -Eeu

readonly KEY_FILE_DIR="/etc/ssh"
readonly KEY_FILE_BAK_DIR="/opt/ssh/keys"

check_host_key()
{
    KEY_FILE_NAME="${1}"
    KEY_FILE_PATH="${KEY_FILE_DIR}/${KEY_FILE_NAME}"
    KEY_FILE_BAK_PATH="${KEY_FILE_BAK_DIR}/${KEY_FILE_NAME}"

    if [ -e "${KEY_FILE_BAK_PATH}" ]; then
        echo "Restoring ssh key from ${KEY_FILE_BAK_PATH}"
        cp -f "${KEY_FILE_BAK_PATH}" "${KEY_FILE_PATH}"
    else
        echo "Backing up new ssh key ${KEY_FILE_PATH}"
        cp -f "${KEY_FILE_PATH}" "${KEY_FILE_BAK_PATH}"
    fi
}

main()
{
    check_host_key ssh_host_rsa_key
    check_host_key ssh_host_ed25519_key
}

main
