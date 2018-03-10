#!/bin/bash
set -e
notes_path="${HOME}/Documents/notes"

if [ $# -gt 0 ]; then
    while getopts ":s:h" opt; do
        case "$opt" in
            s )
                grep -ir --color=auto "$OPTARG" "$notes_path"
                ;;
            \? )
                echo "Invalid options: -$OPTARG" >&2
                exit 1
                ;;
            : )
                echo "Option -$OPTARG requires a regex or quoted text argument" >&2
                exit 1
                ;;
            h )
                echo "Usage:"
                echo "    $0 -h                       Display this help message"
                echo "    $0 -s PATTERN               Searches $notes_path for PATTERN"
                echo "    $0                          Opens today's notes file for editing"
                ;;
        esac
    done
else
    # Today's filename
    filename="${notes_path}/$(date +%y-%m-%d).md"
    touch "${filename}"
    # Make read/writeable only by user
    chmod 600 "${filename}"

    today="$(date '+%A %B %d at %I:%M%P')"
    if [[ -s ${filename} ]];
    then
        # File is not empty, add newline before and after the new heading
        {
            echo ""
            echo "# ${today}"
            echo ""
        } >> "${filename}"
    else
        # File is empty, add the first heading
        echo "# ${today}" >> "${filename}"
    fi

    vim "${filename}"
fi

