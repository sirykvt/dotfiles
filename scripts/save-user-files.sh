#!/bin/bash

# 1. Check that the script is NOT RUN AS ROOT
# User files must be copied under the current user's authority.
if [ "$EUID" -eq 0 ]; then
  echo "Error: Do not run this script using sudo!"
  exit 1
fi

# Directory inside the repo where configs will be stored (structure will be ./home/...)
DEST="./user"
rm -R "$DEST"
mkdir -p "$DEST"

echo "User: $USER"
echo "Copying user configurations..."
echo "---"

# Copy function
# Accepts path relative to the home directory.
# copy_item ".config/kitty" will copy to "./home/.config/kitty"
copy_item() {
    FILE_PATH="$1"
    FULL_SRC="$HOME/$FILE_PATH"
    FULL_DEST="$DEST/$FILE_PATH"

    if [ -e "$FULL_SRC" ]; then
        # Create the destination folder structure
        mkdir -p "$(dirname "$FULL_DEST")"
        
        # -r (recursive) allows copying both files and entire directories
        # -L (dereference) if it's a symlink, copy the actual file/directory, not the link
        cp -rL "$FULL_SRC" "$FULL_DEST"
        echo "Successfully saved $FILE_PATH"
    else
        echo "Warning: $FILE_PATH not found (skipping)"
    fi
}

# --- FILE AND DIRECTORY LIST (relative to ~/) ---

# Shell
copy_item ".zshrc"
copy_item ".gitconfig"

copy_item ".config/ashell"
copy_item ".config/walker"
copy_item ".config/dunst"
copy_item ".config/hypr"
copy_item ".config/kitty"
copy_item ".config/uwsm"
copy_item ".config/yazi"
copy_item ".config/nwg-look"

copy_item ".config/gtk-3.0/settings.ini"
copy_item ".gtkrc-2.0"
copy_item ".icons/default/index.theme"
copy_item ".config/xsettingsd/xsettingsd.conf"
copy_item ".config/gtk-4.0"

echo "---"
echo "Done! Files copied to the $DEST folder."