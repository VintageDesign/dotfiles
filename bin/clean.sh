#!/bin/sh

set -o errexit
# set -o pipefail
set -o nounset

usage() {
    echo ""
    echo "    Usage: $0 <number of spaces> <filename>"
    echo ""
    echo "Converts tabs to the specified number of spaces and strips trailing whitespace from the given file,"
    echo "in addition to ensuring that there is one and only one newline at the end of the file."
    echo ""
}

main() {
    if [ $# -ne 2 ]; then
        usage
        exit 1
    else
        echo "Stripping trailing whitespace."
        sed -i 's/[ \t]*$//' "$2"

        echo "Converting tabs to spaces."
        expand -i --tabs="$1" "$2" | sponge "$2"

        echo "Ensuring only one newline at end of file"
        awk '/^$/ {nlstack=nlstack "\n";next;} {printf "%s",nlstack; nlstack=""; print;}' "$2" | sponge "$2"
    fi
}

main "$@"

#for f in `ls *.tex`; do clean.sh 4 $f; done
