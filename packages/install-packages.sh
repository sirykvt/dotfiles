#!/bin/bash

set -e
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

TMP_DIR="${SCRIPT_DIR}/tmp"
rm -rf "${TMP_DIR}"
mkdir -p "${TMP_DIR}"

install_yay() {
	if [[ -x /usr/bin/yay ]]; then
		echo "yay is installed, skipping..."
		return
	fi

	echo "Installing yay..."
	git clone https://aur.archlinux.org/yay.git "${TMP_DIR}/yay"
	cd "${TMP_DIR}/yay"
	makepkg -si
	cd -
}

install_system() {
	SYSTEM_PKGS=(
		snapper
		zsh
		seatd
		greetd
		greetd-tuigreet
		pipewire
		pipewire-pulse
		pipewire-alsa
		pipewire-jack
		wireplumber
		pwvucontrol
		gvfs
	)
	yay -S --noconfirm --needed "${SYSTEM_PKGS[@]}"

	if [[ ! -f "/etc/snapper/configs/root" ]]; then
		sudo snapper -c root create-config /
	fi

	if [[ ! -x /usr/bin/zsh ]]; then
		sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
		chsh -s /bin/zsh
	fi

	sudo systemctl enable seatd
	sudo systemctl disable getty@tty1.service
	sudo systemctl enable greetd.service
}

install_nvidia() {
	NVIDIA_PKGS=(
		nvidia-open
		nvidia-utils
		nvidia-settings
	)
	yay -S --noconfirm --needed "${NVIDIA_PKGS[@]}"
}

install_wm() {
	WM_PKGS=(
		uwsm
		hyprland
		hyprpolkitagent
		xdg-desktop-portal
		xdg-desktop-portal-hyprland
		dunst
		grim
		slurp
		geoclue
		xorg-xwayland
		hyprpaper
		wl-clipboard
		waybar
		elephant-all
		walker
	)
	yay -S --noconfirm --needed "${WM_PKGS[@]}"

	systemctl --user enable hyprpolkitagent
}

install_appearance() {
	APPEARANCE_PKGS=(
		ttf-jetbrains-mono-nerd
		ttf-noto-nerd
		ttf-droid
		noto-fonts-emoji
		nwg-look
		gnome-themes-extra
		papirus-icon-theme
		qt6ct
	)
	yay -S --noconfirm --needed "${APPEARANCE_PKGS[@]}"
}

install_dev() {
	DEV_PKGS=(
		shfmt
		gcc
		make
		cmake
		clang
		github-cli
		neovim
		rider
		zed
	)
	yay -S --noconfirm --needed "${DEV_PKGS[@]}"

	DEPS_PKGS=(
		base-devel
		libusb
		hidapi
		dotnet-sdk
	)
	yay -S --noconfirm --needed "${DEPS_PKGS[@]}"
}

install_cli() {
	CLI_PKGS=(
		fastfetch
		unzip
		imagemagick
		ffmpeg
		7zip
		jq
		fd
		ripgrep
		zf
		zoxide
		resvg
		chafa
		yazi
		btop
		systemctl-tui
	)
	yay -S --noconfirm --needed "${CLI_PKGS[@]}"
}

install_apps() {
	APPS_PKGS=(
		kitty
		pcmanfm
		google-chrome
		telegram-desktop
	)
	yay -S --noconfirm --needed "${APPS_PKGS[@]}"
}

install_games() {
	GAMES_PKGS=(
		steam
	)
	yay -S --noconfirm --needed "${GAMES_PKGS[@]}"
}

install_g810_led() {
	if [[ -x /usr/bin/g810-led ]]; then
		echo "g810-led is installed, skipping..."
		return
	fi

	echo "Installing g810-led..."
	git clone https://github.com/sirykvt/g810-led.git "${TMP_DIR}/g810-led"
	cd "${TMP_DIR}/g810-led"
	make
	sudo make install
	cd -
}

echo "Installing packages..."
echo "---"

install_yay
install_system
install_nvidia
install_wm
install_appearance
install_dev
install_cli
install_apps
install_games
install_g810_led

echo "---"
