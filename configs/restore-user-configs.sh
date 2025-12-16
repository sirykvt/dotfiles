#!/bin/bash

set -e

if [ "$EUID" -eq 0 ]; then
  echo "Error: Do not run this script using sudo!"
  exit 1
fi

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

SRC="${SCRIPT_DIR}/user"
TARGET="$HOME"

if [ ! -d "$SRC" ]; then
    echo "Error: Source directory '$SRC' not found!"
    echo "Make sure you run this script from the root of your repo."
    exit 1
fi

echo "User: $USER"
echo "Source: $SRC"
echo "Target: $TARGET"
echo "---"

echo "Restoring configurations..."

# -r (recursive) copy directories
# -v (verbose) show what is being copied
# The dot "." at the end of the source path is crucial!
# It means "contents of the directory" (including hidden files like .zshrc),
# rather than copying the "user" folder itself into home.
cp -rv "$SRC/." "$TARGET/"

echo "Updating XDG directories..."
xdg-user-dirs-update --force

echo "---"
echo "Restore complete!"
