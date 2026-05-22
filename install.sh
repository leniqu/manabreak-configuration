#!/usr/bin/env bash

set -e

echo "🌌 Starting Manabreak Quickshell setup..."

# 1. Detect OS
if [ -f /etc/os-release ]; then
    . /etc/os-release
    OS=$ID
else
    echo "❌ Cannot detect OS distribution. /etc/os-release missing."
    exit 1
fi

echo "🔍 Detected OS: $OS"

# 2. Install dependencies based on OS
case "$OS" in
    gentoo)
        echo "📦 Installing dependencies via emerge (Gentoo)..."
        echo "⚠️  Note: Ensure your USE flags and keyword acceptances are set if needed."
        sudo emerge --ask=n --changed-use \
            sys-apps/quickshell \
            gui-wm/hyprland \
            dev-libs/glib \
            gui-apps/swaync \
            x11-terms/kitty \
            net-misc/networkmanager \
            x11-misc/pywal \
            gui-apps/waypaper \
            media-fonts/rubik
        ;;
    arch)
        echo "📦 Installing dependencies via pacman & AUR helper (Arch)..."
        if command -v paru &> /dev/null; then
            AUR_HELPER="paru"
        elif command -v yay &> /dev/null; then
            AUR_HELPER="yay"
        else
            echo "❌ Error: Neither 'paru' nor 'yay' was found. Please install an AUR helper first."
            exit 1
        fi
        
        sudo pacman -S --needed --noconfirm \
            hyprland glib2 swaync kitty networkmanager python-pywal waypaper ttf-rubik
        
        $AUR_HELPER -S --needed --noconfirm quickshell-git
        ;;
    debian)
        echo "📦 Installing dependencies via apt (Debian)..."
        echo "⚠️  Note: quickshell and hyprland might require building from source or external repos on Debian."
        sudo apt update
        sudo apt install -y \
            libglib2.0-dev kitty network-manager python3-pip waypaper fonts-rubik
        
        # Checking if swaync is available in apt, otherwise it needs manual build
        if ! apt-cache show swaync &> /dev/null; then
            echo "⚠️  swaync not found in default Debian repositories. Please install it manually."
        else
            sudo apt install -y swaync
        fi
        ;;
    *)
        echo "❌ Unsupported OS: $OS. Please install dependencies manually."
        exit 1
        ;;
esac

# 3. Setup Configuration Directory
TARGET_DIR="$HOME/.config/quickshell"

if [ -d "$TARGET_DIR" ]; then
    echo "⚠️  Directory $TARGET_DIR already exists."
    echo "📦 Backing up your old configuration to ~/.config/quickshell_backup..."
    rm -rf "$HOME/.config/quickshell_backup"
    mv "$TARGET_DIR" "$HOME/.config/quickshell_backup"
fi

# 4. Clone the repository
echo "📥 Cloning manabreak-configuration..."
git clone https://github.com "$TARGET_DIR"

echo "✅ Installation complete!"
echo "🚀 Run it using: quickshell --config ~/.config/quickshell"
