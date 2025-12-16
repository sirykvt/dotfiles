#!/bin/bash

set -e

if [ "$EUID" -ne 0 ]; then
  echo "Error: This script must be run as root!"
  echo "Please run: sudo $0"
  exit 1
fi

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

SRC="${SCRIPT_DIR}/system"
TARGET="/"

if [ ! -d "$SRC" ]; then
    echo "Error: Source directory '$SRC' not found!"
    echo "Make sure you run this script from the root of your repo."
    exit 1
fi

echo "--- SYSTEM RESTORE ---"
echo "Source: $SRC"
echo "Target: $TARGET"
echo "WARNING: This will overwrite system-wide configurations."
echo "---"

read -p "Are you sure you want to proceed? (y/N): " confirm
if [[ $confirm != [yY] && $confirm != [yY][eE][sS] ]]; then
    echo "Aborted."
    exit 0
fi

echo "Restoring system configurations..."

# -r (recursive) copy directories
# -v (verbose) show what is being copied
# Copy contents of ./system into / (root directory)
# For example, ./system/etc/pacman.conf becomes /etc/pacman.conf
cp -rv "$SRC/." "$TARGET/"

echo "---"
echo "System restore complete!"
