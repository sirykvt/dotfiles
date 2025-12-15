#!/bin/bash

# 1. Check if the script is run as root (via sudo)
if [ "$EUID" -ne 0 ]; then
  echo "Error: Please run the script using sudo!"
  exit 1
fi

# 2. Determine the actual user who invoked sudo
if [ -n "$SUDO_USER" ]; then
    REAL_USER=$SUDO_USER
    # Determine the user's group (usually matches the username, but better to check)
    REAL_GROUP=$(id -gn $SUDO_USER)
else
    echo "Error: Could not determine SUDO_USER. Are you logged in directly as root?"
    exit 1
fi

# Directory inside the repo where configs will be stored
DEST="./system"
mkdir -p "$DEST"

echo "Real User: $REAL_USER:$REAL_GROUP"
echo "Copying system configurations..."
echo "---"

# Function to copy files while preserving the path structure
# copy_file "/etc/pacman.conf" will become "./root_files/etc/pacman.conf"
copy_file() {
    if [ -f "$1" ]; then
        # Create the destination folder (e.g., root_files/etc/)
        mkdir -p "$DEST$(dirname "$1")"
        # Copy the file
        cp "$1" "$DEST$1"
        echo "$1 saved"
    else
        echo "Warning: $1 not found (skipping)"
    fi
}

# --- FILE LIST ---
copy_file "/etc/pacman.conf"
copy_file "/etc/mkinitcpio.conf"
copy_file "/etc/locale.gen"
copy_file "/etc/locale.conf"
copy_file "/etc/vconsole.conf"
copy_file "/etc/hostname"
copy_file "/etc/sudoers"
copy_file "/etc/environment"
copy_file "/etc/greetd/config.toml"

echo "---"

# 3. Change ownership of all copied files back to the real user
echo "Fixing permissions..."
chown -R "$REAL_USER:$REAL_GROUP" "$DEST"

echo "Done! Files copied and owned by user $REAL_USER."