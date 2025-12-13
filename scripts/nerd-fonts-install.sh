
# This script automates the installation of Nerd Fonts.
# It allows for selection of multiple fonts, handles dependencies, and can install globally or locally.

# --- Configuration ---

# Default Nerd Fonts version.
# Check https://github.com/ryanoasis/nerd-fonts/releases for the latest version.
DEFAULT_VERSION="3.2.1" # Using a stable version. Update this if you prefer a newer specific version.

# Local installation directory
LOCAL_FONTS_DIR="${HOME}/.local/share/fonts/NerdFonts"

# Global installation directory (requires sudo)
GLOBAL_FONTS_DIR="/usr/local/share/fonts/NerdFonts"

# Array of available Nerd Fonts to choose from
declare -A ALL_FONTS=(
    ["Agave"]="Agave.zip"
    ["AnonymousPro"]="AnonymousPro.zip"
    ["Arimo"]="Arimo.zip"
    ["AurulentSansMono"]="AurulentSansMono.zip"
    ["BigBlueTerminal"]="BigBlueTerminal.zip"
    ["BitstreamVeraSansMono"]="BitstreamVeraSansMono.zip"
    ["CascadiaCode"]="CascadiaCode.zip"
    ["CascadiaMono"]="CascadiaMono.zip" # For NO ligatures version
    ["CodeNewRoman"]="CodeNewRoman.zip"
    ["CommitMono"]="CommitMono.zip"
    ["Cousine"]="Cousine.zip"
    ["DaddyTimeMono"]="DaddyTimeMono.zip"
    ["DejaVuSansMono"]="DejaVuSansMono.zip"
    ["DroidSansMono"]="DroidSansMono.zip"
    ["FantasqueSansMono"]="FantasqueSansMono.zip"
    ["FiraCode"]="FiraCode.zip"
    ["FiraMono"]="FiraMono.zip"
    ["Go-Mono"]="Go-Mono.zip"
    ["Gohu"]="Gohu.zip"
    ["Hack"]="Hack.zip"
    ["Hasklig"]="Hasklig.zip"
    ["HeavyData"]="HeavyData.zip"
    ["Hermit"]="Hermit.zip"
    ["iA-Writer"]="iA-Writer.zip"
    ["IBMPlexMono"]="IBMPlexMono.zip"
    ["Inconsolate"]="Inconsolata.zip"
    ["InconsolataGo"]="InconsolataGo.zip"
    ["InconsolataLGC"]="InconsolataLGC.zip"
    ["Iosevka"]="Iosevka.zip"
    ["JetBrainsMono"]="JetBrainsMono.zip"
    ["Lekton"]="Lekton.zip"
    ["LiberationMono"]="LiberationMono.zip"
    ["Lilex"]="Lilex.zip"
    ["Meslo"]="Meslo.zip"
    ["Monofur"]="Monofur.zip"
    ["Mononoki"]="Mononoki.zip"
    ["Monoid"]="Monoid.zip"
    ["MPlus"]="MPlus.zip"
    ["NerdFontsSymbolsOnly"]="NerdFontsSymbolsOnly.zip"
    ["Noto"]="Noto.zip"
    ["OpenDyslexic"]="OpenDyslexic.zip"
    ["Overpass"]="Overpass.zip"
    ["ProFont"]="ProFont.zip"
    ["ProggyClean"]="ProggyClean.zip"
    ["RobotoMono"]="RobotoMono.zip"
    ["ShareTechMono"]="ShareTechMono.zip"
    ["Terminus"]="Terminus.zip"
    ["Tinos"]="Tinos.zip"
    ["Ubuntu"]="Ubuntu.zip"
    ["UbuntuMono"]="UbuntuMono.zip"
    ["VictorMono"]="VictorMono.zip"
)

# --- Variables for script execution ---
INSTALL_DIR=""
SUDO_PREFIX=""
SELECTED_FONTS=()
FONT_VERSION=""

# --- Functions ---

# Function to check for required commands
check_dependencies() {
    local missing_deps=()
    for cmd in wget unzip fc-cache; do
        if ! command -v "$cmd" &> /dev/null; then
            missing_deps+=("$cmd")
        fi
    done

    if [[ ${#missing_deps[@]} -gt 0 ]]; then
        echo "Error: The following required commands are not installed: ${missing_deps[*]}"
        echo "Please install them using your system's package manager (e.g., sudo pacman -S ${missing_deps[*]} or sudo apt-get install ${missing_deps[*]})."
        exit 1
    fi
}

# Function to get the latest Nerd Fonts version
get_latest_version() {
    echo "Attempting to fetch the latest Nerd Fonts version from GitHub..."
    # Using GitHub API to get the latest release tag name
    local latest_version=$(wget -qO- https://api.github.com/repos/ryanoasis/nerd-fonts/releases/latest | grep -oP '"tag_name": "\K[^"]+')

    if [[ -n "$latest_version" ]]; then
        # Remove 'v' prefix if present (e.g., v3.2.1 -> 3.2.1)
        echo "${latest_version#v}"
    else
        echo "Could not fetch the latest version. Using default version: $DEFAULT_VERSION" >&2
        echo "$DEFAULT_VERSION"
    fi
}

# Function to prompt user for installation type (local/global)
prompt_installation_type() {
    echo ""
    echo "Choose installation type:"
    echo "1) Local (for current user only - recommended, installs to $LOCAL_FONTS_DIR)"
    echo "2) Global (for all users - requires sudo, installs to $GLOBAL_FONTS_DIR)"
    read -p "Enter choice (1 or 2): " choice
    case "$choice" in
        1) INSTALL_DIR="$LOCAL_FONTS_DIR";;
        2) INSTALL_DIR="$GLOBAL_FONTS_DIR"; SUDO_PREFIX="sudo";;
        *) echo "Invalid choice. Exiting."; exit 1;;
    esac

    echo "Fonts will be installed to: $INSTALL_DIR"
}

# Function to prompt user for font selection
prompt_font_selection() {
    echo ""
    echo "Available Nerd Fonts (select by number, space-separated, e.g., '1 5 12'):"
    local i=1
    local font_names_ordered=()
    for font_name in "${!ALL_FONTS[@]}"; do
        echo "$i) $font_name"
        font_names_ordered+=("$font_name")
        i=$((i+1))
    done

    read -p "Your selection: " selections_input

    # Process user input
    for sel in $selections_input; do
        if [[ "$sel" =~ ^[0-9]+$ ]] && [[ "$sel" -ge 1 && "$sel" -le ${#font_names_ordered[@]} ]]; then
            SELECTED_FONTS+=("${font_names_ordered[$((sel-1))]}")
        else
            echo "Warning: Invalid selection '$sel' ignored." >&2
        fi
    done

    if [[ ${#SELECTED_FONTS[@]} -eq 0 ]]; then
        echo "No valid fonts selected. Exiting."
        exit 1
    fi

    echo ""
    echo "You selected the following fonts:"
    for font in "${SELECTED_FONTS[@]}"; do
        echo "- $font"
    done
}

# Function to download and install fonts
install_fonts() {
    echo ""
    echo "Starting font installation..."

    # Check for sudo if global installation is chosen but not run as root
    if [[ "$SUDO_PREFIX" == "sudo" && $EUID -ne 0 ]]; then
        echo "Error: Global installation requires superuser privileges." >&2
        echo "Please re-run this script with 'sudo' (e.g., sudo ./scripts/nerd-fonts-install.sh)." >&2
        exit 1
    fi

    # Create installation directory if it doesn't exist
    if ! $SUDO_PREFIX mkdir -p "$INSTALL_DIR"; then
        echo "Error: Failed to create directory $INSTALL_DIR. Check permissions." >&2
        exit 1
    fi

    for font_name in "${SELECTED_FONTS[@]}"; do
        local zip_file="${ALL_FONTS[$font_name]}"
        local download_url="https://github.com/ryanoasis/nerd-fonts/releases/download/v${FONT_VERSION}/${zip_file}"
        local tmp_zip="/tmp/${zip_file}"

        echo "Downloading ${font_name} from $download_url..."
        if ! wget -q --show-progress "$download_url" -O "$tmp_zip"; then
            echo "Error: Failed to download ${font_name}. Skipping this font." >&2
            continue
        fi

        echo "Extracting ${font_name} to ${INSTALL_DIR}..."
        if ! $SUDO_PREFIX unzip -o "$tmp_zip" -d "$INSTALL_DIR"; then
            echo "Error: Failed to unzip ${font_name}. Skipping this font." >&2
            rm -f "$tmp_zip"
            continue
        fi

        # Clean up temporary zip file
        rm -f "$tmp_zip"
        echo "${font_name} installed."
    done

    echo ""
    echo "Cleaning up 'Windows Compatible' files (if any)..."
    $SUDO_PREFIX find "$INSTALL_DIR" -name '*Windows Compatible*' -delete

    echo "Updating font cache..."
    if ! $SUDO_PREFIX fc-cache -fv; then
        echo "Warning: Failed to update font cache. You might need to run 'fc-cache -fv' manually." >&2
    else
        echo "Font cache updated successfully."
    fi

    echo ""
    echo "Nerd Fonts installation complete! Please restart your terminal or applications to use the new fonts."
}

# --- Main Script Execution ---

check_dependencies

FONT_VERSION=$(get_latest_version)
echo "Using Nerd Fonts release version: $FONT_VERSION"

prompt_installation_type
prompt_font_selection
install_fonts
