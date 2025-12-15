#!/bin/bash

# 1. Check that the script IS RUN AS ROOT
# System files require root privileges to write to /etc, /boot, etc.
if [ "$EUID" -ne 0 ]; then
  echo "Error: This script must be run as root!"
  echo "Please run: sudo $0"
  exit 1
fi

# Source directory (inside the repo)
SRC="./system"
# Destination directory (System Root)
TARGET="/"

# Check if the source directory exists
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

# 2. CONFIRMATION
# Since this affects the OS stability, it's good practice to ask.
read -p "Are you sure you want to proceed? (y/N): " confirm
if [[ $confirm != [yY] && $confirm != [yY][eE][sS] ]]; then
    echo "Aborted."
    exit 0
fi

# 3. RESTORE PROCESS
echo "Restoring system configurations..."

# -r (recursive) copy directories
# -v (verbose) show what is being copied
# Copy contents of ./system into / (root directory)
# For example, ./system/etc/pacman.conf becomes /etc/pacman.conf
cp -rv "$SRC/." "$TARGET/"

echo "---"
echo "System restore complete!"