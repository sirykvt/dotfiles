#!/bin/bash

set -e

if [ "$EUID" -eq 0 ]; then
	echo "Error: Do not run this script using sudo!"
	exit 1
fi

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

DEST="${SCRIPT_DIR}/user"
mkdir -p "${DEST}"

echo "Real User: $REAL_USER:$REAL_GROUP"
echo "Copying user configurations..."
echo "---"

copy_file() {
    FILE_PATH="$1"
    FULL_SRC="$HOME/$FILE_PATH"
    FULL_DEST="$DEST/$FILE_PATH"

    if [ -e "$FULL_SRC" ]; then
        mkdir -p "$(dirname "$FULL_DEST")"
        
        # -r (recursive) allows copying both files and entire directories
        # -L (dereference) if it's a symlink, copy the actual file/directory, not the link
        cp -rL "$FULL_SRC" "$FULL_DEST"
        echo "$FILE_PATH"
    else
        echo "NOT FOUND: $FILE_PATH"
    fi
}

mapfile -t CONFIGS < <(grep -Ev '^[[:space:]]*(#|$)' "${SCRIPT_DIR}/user-configs.ini")
for CONFIG in "${CONFIGS[@]}"; do
	copy_file "${CONFIG}"
done

echo "---"
echo "Done! Files copied to the $DEST folder."
