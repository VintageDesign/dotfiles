#!/usr/bin/env bash
set -o errexit
set -o pipefail
set -o nounset

SOURCE="${BASH_SOURCE[0]}"
# resolve $SOURCE until the file is no longer a symlink
while [ -h "$SOURCE" ]; do
    DIR="$(cd -P "$(dirname "$SOURCE")" >/dev/null 2>&1 && pwd)"
    SOURCE="$(readlink "$SOURCE")"
    # if $SOURCE was a relative symlink, we need to resolve it relative to the path where the symlink file was located
    [[ $SOURCE != /* ]] && SOURCE="$DIR/$SOURCE"
done
CONFIG_DIR="$(cd -P "$(dirname "$SOURCE")" >/dev/null 2>&1 && pwd)/.."
CONFIG_DIR="$(readlink --canonicalize --no-newline "${CONFIG_DIR}")"
echo "Found configuration directory: ${CONFIG_DIR}"

read -p "Update dotfiles and vim plugins? (y/N) " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    echo "Updating dotfiles and plugins..."
    (cd "${CONFIG_DIR}" && git pull && git submodule update --remote --recursive --init)
fi

read -p "Install fzf? (y/N) " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    echo "Installing fzf..."
    ~/.fzf/install --all
    echo "Done installing fzf"
fi

read -p "Install shellcheck and shfmt? (y/N) " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    echo "Installing shellcheck..."
    export scversion="latest"
    curl -L "https://storage.googleapis.com/shellcheck/shellcheck-${scversion}.linux.x86_64.tar.xz" -o ~/Downloads/shellcheck.tar.xz
    tar -xJf ~/Downloads/shellcheck.tar.xz --directory "$HOME"/Downloads
    cp ~/Downloads/shellcheck-"${scversion}"/shellcheck ~/.local/bin
    chmod +x ~/.local/bin/shellcheck
    echo "Installed shellcheck version:"
    shellcheck --version
    echo
    echo "Installing shmft..."
    # NOTE: There is a newer release, but no prebuilt binaries.
    curl -L https://github.com/mvdan/sh/releases/download/v2.6.4/shfmt_v2.6.4_linux_amd64 -o ~/Downloads/shfmt
    cp ~/Downloads/shfmt ~/.local/bin
    chmod +x ~/.local/bin/shfmt
    echo "Installed shellcheck version: $(shfmt --version)"
fi

read -p "Install git, vim, and curl? (y/N) " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    echo "Installing git, vim, and curl..."
    sudo apt install git vim curl
fi

read -p "Install LaTeX? (y/N) " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    echo "Installing texlive, chktex, pdf2svg, and pandoc..."
    sudo apt install texlive-full chktex pdf2svg pandoc
fi

read -p "Install dev packages? (y/N) " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    echo "Installing dev packages..."
    sudo apt install gcc g++ clang clang-format clang-tidy gdb valgrind make cmake doxygen graphviz python3-dev optipng
fi

read -p "Install useful utilities? (y/N) " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    echo "Installing utilities...."
    sudo apt install htop nmap traceroute screen screenfetch linux-tools-common linux-tools-generic openssh-server tree iperf net-tools nfs-common pv
fi

read -p "Install tweaks? (y/N) " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    echo "Installing tweaks..."
    sudo add-apt-repository ppa:numix/ppa -y
    sudo add-apt-repository ppa:mikhailnov/pulseeffects -y
    sudo apt install gnome-tweak-tool chrome-gnome-shell numix-gtk-theme numix-icon-theme-circle pulseeffects
fi

read -p "Install VS Code? (y/N) " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    echo "Installing VS Code and setting-sync..."
    curl -L https://go.microsoft.com/fwlink/?LinkID=760868 -o ~/Downloads/code.deb
    sudo apt install ~/Downloads/code.deb
    code --install-extension shan.code-settings-sync
    echo "See: https://marketplace.visualstudio.com/items?itemName=Shan.code-settings-sync"
fi

read -p "Install Discord and Spotify? (y/N) " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    echo "Installing Discord..."
    curl -L "https://discordapp.com/api/download?platform=linux&format=deb" -o ~/Downloads/discord.deb
    sudo apt install ~/Downloads/discord.deb
    echo "Installed Discord."
    echo "Installing Spotify..."
    sudo apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys 931FF8E79F0876134EDDBDCCA87FF9DF48BF1C90
    echo deb http://repository.spotify.com stable non-free | sudo tee /etc/apt/sources.list.d/spotify.list
    sudo apt-get update
    sudo apt-get install spotify-client
    echo "Installed Spotify."
fi

read -p "Install Steam, Minecraft, and Lutris? (y/N) " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    echo "Installing Steam..."
    sudo apt install steam
    echo "Installed Steam."
    echo "Installing Minecraft..."
    curl -L https://launcher.mojang.com/download/Minecraft.deb -o ~/Downloads/minecraft.deb
    sudo apt install ~/Downloads/minecraft.deb
    echo "Installed Minecraft."
    echo "Installing Lutris..."
    sudo add-apt-repository ppa:lutris-team/lutris -y
    sudo apt install lutris
    echo "Installed Lutris."
fi

# Note that this installs pip for python3 under `pip` instead of `pip3`.
read -p "Install Pip and Python3 development tools? (y/N) " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    echo "Checking for pip..."
    if [ ! -f "$(command -v pip)" ]; then
        echo "Pip not installed. Installing Pip..."
        curl https://bootstrap.pypa.io/get-pip.py -o ~/Downloads/get-pip.py
        read -p "Install Pip as user? (y/N) " -n 1 -r
        echo

        # The get-pip.py script requires python3-distutils.
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            python3 ~/Downloads/get-pip.py --user
        else
            sudo -H python3 ~/Downloads/get-pip.py
        fi
        echo "Installed Pip $(pip --version)"
    else
        echo "Found Pip $(pip --version)"
    fi

    read -p "Install Python development packages for $(pip --version | grep -o '(.*)')? (y/N) " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        echo "Installing development packages without a virtualenv..."
        # These packages are required by e.g., ~/bin/notes and VS Code Python config.
        pip install --upgrade --user virtualenv pygments ipython parsedatetime pylint pydocstyle black
        echo "Install all other packages in a virtualenv!"
    fi
    # TODO: Figure out how jupyter and nb-pdf-template work in a virtualenv.
fi

read -p "Install Gnome Shell extensions? (y/N) " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    xdg-open https://extensions.gnome.org/extension/1319/gsconnect/
    xdg-open https://extensions.gnome.org/extension/1485/workspace-matrix/
fi

read -p "Configure system settings? (y/N) " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    echo "Configuring system settings..."
    gsettings set org.gnome.shell favorite-apps "['firefox.desktop', 'org.gnome.Nautilus.desktop']"
    gsettings set org.gnome.desktop.peripherals.touchpad natural-scroll false
    gsettings set org.gnome.settings-daemon.plugins.color night-light-enabled true
    gsettings set org.gnome.desktop.interface clock-format '12h'
    gsettings set org.gtk.Settings.FileChooser clock-format '12h'
    gsettings set org.gnome.desktop.notifications show-in-lock-screen false
    gsettings set org.gnome.desktop.privacy remember-recent-files false
    gsettings set org.gnome.desktop.datetime automatic-timezone true
    gsettings set org.gnome.settings-daemon.plugins.power sleep-inactive-ac-timeout 3600
    gsettings set org.gnome.settings-daemon.plugins.power sleep-inactive-ac-type 'nothing'
    gsettings set org.gnome.settings-daemon.plugins.power ambient-enabled true
    gsettings set org.gnome.shell.extensions.dash-to-dock dash-max-icon-size 48

    echo "Configuring Gnome tweaks..."
    gsettings set org.gnome.desktop.wm.preferences focus-mode 'sloppy'
    org.gnome.desktop.interface icon-theme 'Numix-Circle'
    org.gnome.desktop.interface gtk-theme 'Yaru-dark'
    org.gnome.desktop.interface clock-show-weekday true
    org.gnome.shell.extensions.desktop-icons show-trash false
    org.gnome.shell.extensions.desktop-icons show-home false
    org.gnome.mutter workspaces-only-on-primary false

    echo "Configuring PulseEffects..."
    gsettings set com.github.wwmm.pulseeffects.sinkinputs plugins "['autogain', 'bass_enhancer', 'limiter', 'gate', 'multiband_gate', 'compressor', 'multiband_compressor', 'convolver', 'exciter', 'crystalizer', 'stereo_tools', 'reverb', 'equalizer', 'deesser', 'crossfeed', 'loudness', 'maximizer', 'filter']"
    gsettings set com.github.wwmm.pulseeffects.sinkinputs.bassenhancer amount 10.0
    gsettings set com.github.wwmm.pulseeffects.sinkinputs.bassenhancer state true
    gsettings set com.github.wwmm.pulseeffects enable-all-apps true
    gsettings set com.github.wwmm.pulseeffects use-dark-theme true
fi

read -p "Configure /etc/fstab for NAS? (y/N) " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    NAS_STATIC_IP=192.168.1.112
    sudo mkdir -p /mnt/{assets,documents,images,plex,projects}
    read -p "Attempt to automount NAS? (y/N) " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        echo "Adding automount settings to /etc/fstab..."
        echo "# Synology NAS NFS shares
${NAS_STATIC_IP}:/volume1/ASSETS       /mnt/assets      nfs defaults 0 0
${NAS_STATIC_IP}:/volume1/DOCUMENTS    /mnt/documents   nfs defaults 0 0
${NAS_STATIC_IP}:/volume1/IMAGES       /mnt/images      nfs defaults 0 0
${NAS_STATIC_IP}:/volume1/PLEX         /mnt/plex        nfs defaults 0 0
${NAS_STATIC_IP}:/volume1/PROJECTS     /mnt/projects    nfs defaults 0 0" | sudo tee -a /etc/fstab >/dev/null
    else
        echo "Adding noauto settings to /etc/fstab..."
        echo "# Synology NAS NFS shares. Note that this is a laptop, and these are local
# IPs. Also note that noauto means they won't be mounted on startup.
${NAS_STATIC_IP}:/volume1/ASSETS       /mnt/assets      nfs user,noauto 0 0
${NAS_STATIC_IP}:/volume1/DOCUMENTS    /mnt/documents   nfs user,noauto 0 0
${NAS_STATIC_IP}:/volume1/IMAGES       /mnt/images      nfs user,noauto 0 0
${NAS_STATIC_IP}:/volume1/PLEX         /mnt/plex        nfs user,noauto 0 0
${NAS_STATIC_IP}:/volume1/PROJECTS     /mnt/projects    nfs user,noauto 0 0" | sudo tee -a /etc/fstab >/dev/null
    fi
fi

read -p "Insult on bad sudo password? (y/N) " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    echo "Defaults    insults" | sudo tee -a /etc/sudoers >/dev/null
fi
