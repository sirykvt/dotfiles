#!/bin/bash

set -e

if [ "$EUID" -ne 0 ]; then
	echo "Error: Please run the script using sudo!"
	exit 1
fi

if [ -n "$SUDO_USER" ]; then
	REAL_USER=$SUDO_USER
	REAL_GROUP=$(id -gn $SUDO_USER)
else
	echo "Error: Could not determine SUDO_USER. Are you logged in directly as root?"
	exit 1
fi

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

DEST="${SCRIPT_DIR}/system"
mkdir -p "${DEST}"

echo "Real User: $REAL_USER:$REAL_GROUP"
echo "Copying system configurations..."
echo "---"

copy_file() {
	if [ -f "$1" ]; then
		mkdir -p "$DEST$(dirname "$1")"
		cp "$1" "$DEST$1"
		echo "$1"
	else
		echo "NOT FOUND: $1"
	fi
}

mapfile -t CONFIGS < <(grep -Ev '^[[:space:]]*(#|$)' "${SCRIPT_DIR}/system-configs.ini")
for CONFIG in "${CONFIGS[@]}"; do
	copy_file "${CONFIG}"
done

echo "---"

echo "Fixing permissions..."
chown -R "$REAL_USER:$REAL_GROUP" "$DEST"

echo "Done! Files copied and owned by user $REAL_USER."
