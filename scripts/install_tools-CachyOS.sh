#!/bin/bash

# Exit on error
set -e

# Color codes for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Functions for colored output
print_header() {
    echo -e "${BLUE}## $1 ##${NC}"
}

print_success() {
    echo -e "${GREEN}✓ $1${NC}"
}

print_error() {
    echo -e "${RED}✗ $1${NC}"
}

print_warning() {
    echo -e "${YELLOW}⚠ $1${NC}"
}

# Display usage information
show_usage() {
    cat << EOF
Usage: ./install_tools(CachyOS).sh [OPTIONS]

OPTIONS:
    -h, --help              Show this help message
    --list                  List all available packages to install
    --skip-confirmation     Skip the confirmation prompt
    --verify                Verify that all tools are properly installed

EXAMPLES:
    ./install_tools(CachyOS).sh
    ./install_tools(CachyOS).sh --list
    ./install_tools(CachyOS).sh --skip-confirmation

EOF
}

# Parse command-line arguments
SKIP_CONFIRMATION=false
VERIFY_ONLY=false

while [[ $# -gt 0 ]]; do
    case $1 in
        -h|--help)
            show_usage
            exit 0
            ;;
        --list)
            VERIFY_ONLY=true
            ;;
        --skip-confirmation)
            SKIP_CONFIRMATION=true
            ;;
        --verify)
            VERIFY_ONLY=true
            ;;
        *)
            print_error "Unknown option: $1"
            show_usage
            exit 1
            ;;
    esac
    shift
done

# =============================================================================
# PACKAGE CONFIGURATION - EASY TO CUSTOMIZE
# =============================================================================

# Main Repository Packages (from official CachyOS/Arch repos)
# Add or remove packages as needed
REPO_PKGS=(
    # Development & Version Control
    git
    github-cli
    lazygit
    stow

    # Navigation & Search
    zoxide

    # Container & System
    docker

    # Terminal & Shell
    starship

    # Applications
    obsidian
    vlc
    qbittorrent

    # Languages & Toolchains
    go
    rustup

    # Editors
    zed

    # Utilities
    localsend
    lazydocker
)

# AUR Packages (from Arch User Repository)
# Add or remove packages as needed
AUR_PKGS=(
    microsoft-edge-stable-bin
)

# =============================================================================
# MAIN SCRIPT
# =============================================================================

print_header "CachyOS Tool Installer"

# Check if paru is installed
if ! command -v paru &> /dev/null; then
    print_error "paru is not installed. Please install paru first."
    echo "Visit: https://github.com/morganamilo/paru"
    exit 1
fi

print_success "paru is available"

# Display packages that will be installed
echo ""
print_header "Packages to be installed"

echo -e "${BLUE}Repository Packages (${#REPO_PKGS[@]}):${NC}"
for pkg in "${REPO_PKGS[@]}"; do
    echo "  • $pkg"
done

echo ""
echo -e "${BLUE}AUR Packages (${#AUR_PKGS[@]}):${NC}"
if [[ ${#AUR_PKGS[@]} -eq 0 ]]; then
    echo "  (none)"
else
    for pkg in "${AUR_PKGS[@]}"; do
        echo "  • $pkg"
    done
fi

echo ""
total_packages=$((${#REPO_PKGS[@]} + ${#AUR_PKGS[@]}))
echo "Total: $total_packages package(s)"

# If only listing, exit here
if [[ "$VERIFY_ONLY" == true ]]; then
    exit 0
fi

# Ask for confirmation before proceeding
if [[ "$SKIP_CONFIRMATION" == false ]]; then
    echo ""
    read -p "Do you want to proceed with the installation? (y/N): " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        print_warning "Installation cancelled."
        exit 0
    fi
fi

# Update system
echo ""
print_header "Updating system"
paru -Syu --noconfirm

# Install repository packages
if [[ ${#REPO_PKGS[@]} -gt 0 ]]; then
    echo ""
    print_header "Installing Repository Packages (${#REPO_PKGS[@]})"
    paru -S --needed --noconfirm "${REPO_PKGS[@]}"
    print_success "Repository packages installed"
fi

# Install AUR packages
if [[ ${#AUR_PKGS[@]} -gt 0 ]]; then
    echo ""
    print_header "Installing AUR Packages (${#AUR_PKGS[@]})"
    paru -S --needed --noconfirm "${AUR_PKGS[@]}"
    print_success "AUR packages installed"
fi

# =============================================================================
# POST-INSTALLATION SETUP
# =============================================================================

echo ""
print_header "Configuring installed tools"

# Docker Setup
if command -v docker &> /dev/null; then
    echo ""
    print_header "Configuring Docker"
    sudo systemctl enable --now docker.service
    print_success "Docker service enabled"

    if ! groups "$USER" | grep &>/dev/null "\bdocker\b"; then
        echo "   Adding $USER to the docker group..."
        sudo usermod -aG docker "$USER"
        print_warning "Please log out and back in for Docker group changes to take effect"
    else
        print_success "User already in docker group"
    fi
fi

# Rust Setup
if command -v rustup &> /dev/null; then
    echo ""
    print_header "Configuring Rust"
    if ! command -v cargo &> /dev/null; then
        rustup default stable
        print_success "Stable Rust toolchain installed"
    else
        print_success "Rust toolchain already configured"
    fi
fi

# LocalSend Firewall Configuration
if command -v localsend &> /dev/null; then
    echo ""
    print_header "Configuring Firewall for LocalSend (Port 53317)"

    if command -v ufw &> /dev/null && sudo ufw status | grep -q "Status: active"; then
        print_warning "Detected UFW"
        sudo ufw allow 53317/tcp comment 'LocalSend' 2>/dev/null || true
        sudo ufw allow 53317/udp comment 'LocalSend' 2>/dev/null || true
        sudo ufw reload 2>/dev/null || true
        print_success "UFW configured for LocalSend"

    elif command -v firewall-cmd &> /dev/null && systemctl is-active --quiet firewalld; then
        print_warning "Detected Firewalld"
        sudo firewall-cmd --permanent --add-port=53317/tcp 2>/dev/null || true
        sudo firewall-cmd --permanent --add-port=53317/udp 2>/dev/null || true
        sudo firewall-cmd --reload 2>/dev/null || true
        print_success "Firewalld configured for LocalSend"
    else
        print_warning "No active firewall detected (UFW/Firewalld). Skipping port configuration."
    fi
fi

# =============================================================================
# COMPLETION
# =============================================================================

echo ""
echo "======================================================================"
print_success "Installation complete!"
echo "======================================================================"
echo ""
echo "Next steps:"
echo "  1. Log out and back in for Docker group changes to take effect"
echo "  2. Run 'stow <package>' to install dotfiles (e.g., stow fish vim)"
echo "  3. Consider installing Nerd Fonts: ./scripts/nerd-fonts-install.sh"
echo ""
