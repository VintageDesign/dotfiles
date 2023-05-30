#!/bin/bash
set -o errexit
set -o pipefail
set -o nounset
set -o noclobber

EMOTICONS_DIR="$HOME/.local/share/emoticons"

usage() {
    echo "Usage: $0 [--help] [--list] [EMOTICON_NAME]"
    echo
    echo "  --help, -h      Show this help and exit"
    echo "  --list, -l      List available emoticons"
}

list_emoticons() {
    for file in "$EMOTICONS_DIR"/*; do
        file="$(basename -- "$file")"
        echo "${file%.*}"
    done
}

random_emoticon() {
    local path
    path="$(find "$EMOTICONS_DIR/" -type f | shuf -n 1)"
    copy_file "$path"
}

grab_emoticon_by_name() {
    local name="$1"
    local path="$EMOTICONS_DIR/$name.txt"
    if [[ -f "$path" ]]; then
        copy_file "$path"
    else
        echo "$path does not exist" >&2
        exit 1
    fi
}

copy_file() {
    local path="$1"
    tee /dev/stderr <"$path" | perl -p -e 'chomp if eof' | clip
}

main() {
    local emoticon=""

    while [[ $# -gt 0 ]]; do
        case "$1" in
        --help | -h)
            usage
            exit 0
            ;;
        --list | -l)
            list_emoticons
            exit 0
            ;;
        -*)
            error "Unexpected option: $1"
            usage >&2
            exit 1
            ;;
        *)
            emoticon="$1"
            ;;
        esac
        shift
    done

    if [[ -z "$emoticon" ]]; then
        random_emoticon
    else
        grab_emoticon_by_name "$emoticon"
    fi
}

main "$@"
