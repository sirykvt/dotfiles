#!/bin/bash

# 1. Check that the script is NOT RUN AS ROOT
# Restoration must be performed under the current user's authority.
# Otherwise, files will be owned by root, causing permission issues.
if [ "$EUID" -eq 0 ]; then
  echo "Error: Do not run this script using sudo!"
  exit 1
fi

# Source directory (inside the repo)
SRC="./user"
# Destination directory (Home)
TARGET="$HOME"

# Check if the source directory exists
if [ ! -d "$SRC" ]; then
    echo "Error: Source directory '$SRC' not found!"
    echo "Make sure you run this script from the root of your repo."
    exit 1
fi

echo "User: $USER"
echo "Source: $SRC"
echo "Target: $TARGET"
echo "---"

# 2. RESTORE PROCESS
echo "Restoring configurations..."

# -r (recursive) copy directories
# -v (verbose) show what is being copied
# The dot "." at the end of the source path is crucial! 
# It means "contents of the directory" (including hidden files like .zshrc),
# rather than copying the "user" folder itself into home.
cp -rv "$SRC/." "$TARGET/"

echo "---"
echo "Restore complete!"