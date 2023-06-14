#!/bin/bash
# shellcheck disable=SC2155
set -o errexit
set -o pipefail
set -o nounset
set -o noclobber

export RED=$(tput setaf 1)
export RESET=$(tput sgr0)

error() {
    echo "${RED}[ERROR]:${RESET} $*" >&2
}

usage() {
    echo "Usage: $0 [--help] [--input]"
    echo
    echo "Filter out WKT geometries from the given input"
    echo
    echo "  --help, -h      Show this help and exit"
    echo "  --input, -i     Input file to filter. Defaults to stdin"
}

main() {
    local input="-"

    while [[ $# -gt 0 ]]; do
        case "$1" in
        --help | -h)
            usage
            exit 0
            ;;
        --input | -i)
            input="$2"
            shift
            ;;
        *)
            error "Unexpected option: $1"
            usage >&2
            exit 1
            ;;
        esac
        shift
    done

    # TODO: MULTI-geometry variants, GEOMETRYCOLLECTION
    # TODO: Consider using a real WKT parser, because regex isn't sufficient to match the right
    # opening/closing parentheses.
    grep -Poi '(LINESTRING|POINT|POLYGON)\s*Z?\s*\(.*?\)+' "$input"
}

main "$@"
