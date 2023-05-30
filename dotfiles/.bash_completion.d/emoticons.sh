#!/bin/bash

_get_available_emoticons() {
    local emoticons_dir="$HOME/.local/share/emoticons"
    for file in "$emoticons_dir"/*; do
        file="$(basename -- "$file")"
        echo "${file%.*}"
    done
}

complete -o nospace -W "--help --list $(_get_available_emoticons)" emoticon.sh
