#!/usr/bin/env bash
set -o errexit
set -o pipefail
set -o nounset

# Deploys the cloned repository into the specified directory.
# The intent is to prevent the home directory from being a git repository
# while still version controlling the dotfiles.

if [ $# -ne 1 ]; then
    echo "Usage: $0 <path to deploy dotfiles to>"
    exit 0
fi

TARGET_DIR=$1

if [ ! -d ${TARGET_DIR} ]; then
    echo "Target directory ${TARGET_DIR} doesn't exist."
    exit 0
fi

SCRIPTPATH="$( cd "$(dirname "$0")" ; pwd -P )"

# The list of things to symlink:
declare -a TARGETS=("bin" ".vim" ".fzf" ".gitconfig" ".pylintrc" ".bashrc" ".bash_aliases")

for t in "${TARGETS[@]}"; do
    SOURCE="${SCRIPTPATH}/${t}"
    TARGET="${TARGET_DIR}/${t}"

    if [ -e "${TARGET}" ]; then
        read -p "Target ${TARGET} exists. Force symlink? (y/N) " -n 1 -r
        echo
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            echo "Forcing Symlink ${SOURCE} -> ${TARGET}"
            ln -sft "${TARGET_DIR}" "${SOURCE}"
        fi
    else
        echo "Symlinking ${SOURCE} -> ${TARGET}"
        ln -sft "${TARGET_DIR}" "${SOURCE}"
    fi

done
