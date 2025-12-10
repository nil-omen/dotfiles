#!/bin/bash

# Exit on error
set -e

echo "## CachyOS Tool Installer ##"
echo "   Ensuring paru is available..."

if ! command -v paru &> /dev/null; then
    echo "Error: paru is not installed. Please install paru first."
    exit 1
fi

echo "## Updating system..."
paru -Syu --noconfirm

# -----------------------------------------------------------------------------
# 1. Define Package Lists
# -----------------------------------------------------------------------------

# CachyOS & Arch Repository Packages
# 'localsend' and 'lazydocker' are available directly in CachyOS repos.
# 'go' and 'rustup' are standard repository packages.
# 'zed' is available in the extra repository.
REPO_PKGS=(
    git
    github-cli
    lazygit
    zoxide
    docker
    starship
    obsidian
    vlc
    qbittorrent
    go
    rustup
    zed
    stow
    localsend
    lazydocker
)

# AUR Packages
# We use '-bin' for Edge to ensure we get the binary release.
AUR_PKGS=(
    microsoft-edge-stable-bin
)

# -----------------------------------------------------------------------------
# 2. Install Packages
# -----------------------------------------------------------------------------

echo "## Installing Repository Packages..."
# --needed skips packages that are already installed and up-to-date
paru -S --needed --noconfirm "${REPO_PKGS[@]}"

echo "## Installing AUR Packages..."
paru -S --needed --noconfirm "${AUR_PKGS[@]}"

# -----------------------------------------------------------------------------
# 3. Post-Installation Setup
# -----------------------------------------------------------------------------

echo "## Configuring Docker..."
sudo systemctl enable --now docker.service
if ! groups "$USER" | grep &>/dev/null "\bdocker\b"; then
    echo "   Adding $USER to the docker group..."
    sudo usermod -aG docker "$USER"
fi

echo "## Configuring Rust..."
if ! command -v cargo &> /dev/null; then
    echo "   Installing stable rust toolchain..."
    rustup default stable
else
    echo "   Rust toolchain already present."
fi

# -----------------------------------------------------------------------------
# 4. Firewall Configuration for LocalSend
# -----------------------------------------------------------------------------
# LocalSend uses TCP/UDP port 53317

echo "## Configuring Firewall for LocalSend (Port 53317)..."

# Check for UFW (Uncomplicated Firewall) - Default on many setups
if command -v ufw &> /dev/null && sudo ufw status | grep -q "Status: active"; then
    echo "   Detected UFW. Allowing port 53317..."
    sudo ufw allow 53317/tcp comment 'LocalSend'
    sudo ufw allow 53317/udp comment 'LocalSend'
    sudo ufw reload
# Check for Firewalld - Default on CachyOS KDE/Some editions
elif command -v firewall-cmd &> /dev/null && systemctl is-active --quiet firewalld; then
    echo "   Detected Firewalld. Allowing port 53317..."
    sudo firewall-cmd --permanent --add-port=53317/tcp
    sudo firewall-cmd --permanent --add-port=53317/udp
    sudo firewall-cmd --reload
else
    echo "   No active firewall detected (UFW/Firewalld). Skipping port opening."
fi

# -----------------------------------------------------------------------------
# 5. Completion
# -----------------------------------------------------------------------------

echo "----------------------------------------------------------------"
echo "Success! All tools installed."
echo "Note: You may need to log out and back in for Docker group changes to take effect."
echo "----------------------------------------------------------------"
