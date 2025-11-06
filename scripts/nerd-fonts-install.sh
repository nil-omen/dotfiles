#!/bin/bash

# make sure to check the lateset font version on the github page 
# and add any fonts that is not shown below if you like 
# https://github.com/ryanoasis/nerd-fonts
# https://www.nerdfonts.com/


# uncomment the fonts you want
declare -a fonts=(
    # Agave
    # AnonymousPro
    # Arimo
    # AurulentSansMono
    # BigBlueTerminal
    # BitstreamVeraSansMono
    # CascaidaCode  # comes by default with windows terminal
	# CascadiaMono  # for NO ligatures vesrion
    # CodeNewRoman
	# CommitMono  # also a nice and small font
    # Cousine
    # DaddyTimeMono
    # DejaVuSansMono
    # DroidSansMono
    # FantasqueSansMono
    # FiraCode
    # FiraMono
    # Go-Mono
    # Gohu
    # Hack  # around 17 MB
    # Hasklig
    # HeavyData
    # Hermit
    # iA-Writer
    # IBMPlexMono
    # Inconsolate
    # InconsolataGo
    # InconsolataLGC
    # Iosevka
    # JetBrainsMono  # very good font but size around 120 MB
    # Lekton
    # LiberationMono
    # Lilex
    Meslo  # great font but big size around 100 MB or a little more
    # Monofur
    # Mononoki  # nice and small font around 14 MB
    # Monoid
    # MPlus
    # NerdFontsSymbolsOnly
    # Noto
    # OpenDyslexic
    # Overpass
    # ProFont
    # ProggyClean
    # RobotoMono
    # ShareTechMono
    # Terminus
    # Tinos
    # Ubuntu
    # UbuntuMono
    # VictorMono  # consider taking a look
)

# enter the version you want
version='3.4.0'

# local location for one user
fonts_dir="${HOME}/.local/share/fonts"

# global location for system wide font installation
# You NEED to be SUDO to install globally
# fonts_dir="/usr/share/fonts/"


if [[ ! -d "$fonts_dir" ]]; then
    mkdir -p "$fonts_dir"
fi

for font in "${fonts[@]}"; do
    zip_file="${font}.zip"
    download_url="https://github.com/ryanoasis/nerd-fonts/releases/download/v${version}/${zip_file}"
    echo "Downloading $download_url"
    wget "$download_url"
    unzip "$zip_file" -d "$fonts_dir"
    rm "$zip_file"
done

find "$fonts_dir" -name '*Windows Compatible*' -delete

fc-cache -fv
