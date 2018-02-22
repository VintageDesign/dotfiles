#!/bin/bash
set -e

notes_path="${HOME}/Documents/notes"
filename="${notes_path}/$(date +%y-%m-%d).md"
touch "${filename}"

today="$(date '+%A %B at %I:%M%P')"
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
