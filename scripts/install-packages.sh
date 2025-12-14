#!/bin/bash

# TODO: Run reflector.

# Stop the script if any command fails.
set -e

sudo pacman -S --noconfirm --needed git github-cli

# yay.
mkdir -p ./tmp
rm -rf ./tmp/yay
git clone https://aur.archlinux.org/yay.git ./tmp/yay
cd ./tmp/yay || exit
makepkg -si
cd -

# zsh.
sudo pacman -S --noconfirm --needed zsh
yay -S --noconfirm --needed spaceship-prompt
chsh -s /bin/zsh

# Nvidia drivers. 
sudo pacman -S --noconfirm --needed nvidia-open nvidia-utils nvidia-settings

# Login manager.
sudo pacman -S --noconfirm --needed greetd greetd-tuigreet seatd
sudo systemctl enable seatd
sudo systemctl disable getty@tty1.service
sudo systemctl enable greetd.service

# Audio (Pipewire).
sudo pacman -S --noconfirm --needed pipewire pipewire-pulse pipewire-alsa pipewire-jack wireplumber
yay -S --noconfirm --needed pwvucontrol

# Fonts.
sudo pacman -S --noconfirm --needed ttf-jetbrains-mono-nerd ttf-noto-nerd ttf-droid

# WM (Hyprland).
sudo pacman -S --noconfirm --needed hyprland uwsm hyprpolkitagent xorg-xwayland
yay -S --noconfirm --needed elephant-all ashell walker

# CLI.
sudo pacman -S --noconfirm --needed imagemagick ffmpeg 7zip jq fd ripgrep fzf zoxide resvg chafa
sudo pacman -S --noconfirm --needed kitty
sudo pacman -S --noconfirm --needed yazi
sudo pacman -S --noconfirm --needed btop

# Apps.
sudo pacman -S --noconfirm --needed code
yay -S --noconfirm --needed google-chrome
sudo pacman -S --noconfirm --needed thunar catfish gvfs tumbler thunar-archive-plugin thunar-volman thunar-media-tags-plugin
