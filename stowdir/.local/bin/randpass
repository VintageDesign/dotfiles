#!/bin/bash
# There's unexpected non-zero exits on what looks like normal data.
# I've spent almost an hour trying to figure out what's actually returning non-zero, and every time
# I think I figured it out, it turns out to be something else.
# set -o errexit
# set -o pipefail
set -o nounset
set -o noclobber

usage() {
    echo "Usage: $0 [--help]"
    echo
    echo "  --help, -h          Show this help and exit"
    echo "  --words, -w         Number of words to pick. Defaults to 4."
    echo "  --no-alliteration, -n  Whether every word should start with the same character"
}

randchar() {
    perl -e 'print(("a".."z")[rand 26])'
}

filter_plurals() {
    grep -v "'s$" "$@"
}

get_all_words() {
    local alliteration="$1"
    local wordlist="$2"

    if [[ "$alliteration" = "true" ]]; then
        local char
        char="$(randchar)"
        grep -i "^$char" "$wordlist" | filter_plurals
    else
        filter_plurals "$wordlist"
    fi
}

normalize() {
    tr '[:upper:]' '[:lower:]'
}

randwords() {
    local words="$1"
    local alliteration="$2"
    local wordlist="/usr/share/dict/words"

    get_all_words "$alliteration" "$wordlist" |
        sort -R |
        head -n "$words" |
        normalize |
        tr '\n' ' '

    echo ""
}

main() {
    local words=4
    local alliteration="true"

    while [[ $# -gt 0 ]]; do
        case "$1" in
        --help | -h)
            usage
            exit 0
            ;;
        --words | -w)
            words="$2"
            shift
            ;;
        --no-alliteration | -n)
            alliteration="false"
            ;;
        -*)
            echo "Unexpected option: $1" >&2
            usage >&2
            exit 1
            ;;
        *)
            echo "Unexpected positional argument: $1" >&2
            exit 1
            ;;
        esac
        shift
    done

    randwords "$words" "$alliteration"
}

main "$@"
