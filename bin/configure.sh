#!/usr/bin/env bash
set -o errexit
set -o pipefail
set -o nounset

UNDERLINE=$(tput sgr 0 1)
BOLD=$(tput bold)
RED=$(tput setaf 1)
GREEN=$(tput setaf 2)
YELLOW=$(tput setaf 3)
WHITE=$(tput setaf 7)
RESET=$(tput sgr0)

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

read -p "${BOLD}${UNDERLINE}Update dotfiles and vim plugins? (y/N)${RESET} " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    echo "${YELLOW}Updating dotfiles and plugins...${RESET}"
    (cd "${CONFIG_DIR}" && git pull && git submodule update --remote --recursive --init)
    echo "${GREEN}Updated dotfiles and plugins.${RESET}"
fi

read -p "${BOLD}${UNDERLINE}Install fzf? (y/N)${RESET} " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    echo "${YELLOW}Installing fzf...${RESET}"
    ~/.fzf/install --all
    echo "${GREEN}Installed fzf.${RESET}"
fi

read -p "${BOLD}${UNDERLINE}Install shellcheck and shfmt? (y/N)${RESET} " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    echo "${YELLOW}Installing shellcheck...${RESET}"
    export scversion="latest"
    curl -L "https://storage.googleapis.com/shellcheck/shellcheck-${scversion}.linux.x86_64.tar.xz" -o ~/Downloads/shellcheck.tar.xz
    tar -xJf ~/Downloads/shellcheck.tar.xz --directory "$HOME"/Downloads
    cp ~/Downloads/shellcheck-"${scversion}"/shellcheck ~/.local/bin
    chmod +x ~/.local/bin/shellcheck
    echo "${GREEN}Installed shellcheck version:${RESET}"
    shellcheck --version
    echo
    echo "${YELLOW}Installing shmft...${RESET}"
    # NOTE: There is a newer release, but no prebuilt binaries.
    curl -L https://github.com/mvdan/sh/releases/download/v2.6.4/shfmt_v2.6.4_linux_amd64 -o ~/Downloads/shfmt
    cp ~/Downloads/shfmt ~/.local/bin
    chmod +x ~/.local/bin/shfmt
    echo "${GREEN}Installed shellcheck version: $(shfmt --version)${RESET}"
fi

read -p "${BOLD}${UNDERLINE}Install git, vim, and curl? (y/N)${RESET} " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    echo "${YELLOW}Installing git, vim, and curl...${RESET}"
    sudo apt install git vim curl
    echo "${GREEN}Installed git, vim, and curl.${RESET}"
fi

read -p "${BOLD}${UNDERLINE}Install LaTeX? (y/N)${RESET} " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    echo "${YELLOW}Installing texlive, chktex, pdf2svg, and pandoc...${RESET}"
    sudo apt install texlive-full chktex pdf2svg pandoc
    echo "${GREEN}Installed texlive, chktex, pdf2svg, and pandoc.${RESET}"
fi

read -p "${BOLD}${UNDERLINE}Install dev packages? (y/N)${RESET} " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    echo "${YELLOW}Installing dev packages...${RESET}"
    sudo apt install gcc g++ clang clang-format clang-tidy gdb valgrind make cmake doxygen graphviz python3-dev optipng
    echo "${GREEN}Installed dev packages.${RESET}"
fi

read -p "${BOLD}${UNDERLINE}Install useful utilities? (y/N)${RESET} " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    echo "${YELLOW}Installing utilities....${RESET}"
    sudo apt install htop nmap traceroute screen screenfetch linux-tools-common linux-tools-generic openssh-server tree iperf net-tools nfs-common pv
    echo "${GREEN}Installed utilities.${RESET}"
fi

read -p "${BOLD}${UNDERLINE}Install tweaks? (y/N)${RESET} " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    echo "${YELLOW}Installing tweaks...${RESET}"
    sudo add-apt-repository ppa:numix/ppa -y
    sudo apt install gnome-tweak-tool chrome-gnome-shell numix-gtk-theme numix-icon-theme-circle
    echo "${GREEN}Installed tweaks.${RESET}"
fi

read -p "${BOLD}${UNDERLINE}Install VS Code? (y/N)${RESET} " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    echo "${YELLOW}Installing VS Code and setting-sync...${RESET}"
    curl -L https://go.microsoft.com/fwlink/?LinkID=760868 -o ~/Downloads/code.deb
    sudo apt install ~/Downloads/code.deb
    code --install-extension shan.code-settings-sync
    echo "${BOLD}${RED}See: https://marketplace.visualstudio.com/items?itemName=Shan.code-settings-sync${RESET}"
    echo "${GREEN}Installed VS Code and settings-sync.${RESET}"
fi

read -p "${BOLD}${UNDERLINE}Install Discord and Spotify? (y/N)${RESET} " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    echo "${YELLOW}Installing Discord...${RESET}"
    curl -L "https://discordapp.com/api/download?platform=linux&format=deb" -o ~/Downloads/discord.deb
    sudo apt install ~/Downloads/discord.deb
    echo "${GREEN}Installed Discord.${RESET}"
    echo "${YELLOW}Installing Spotify...${RESET}"
    sudo apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys 931FF8E79F0876134EDDBDCCA87FF9DF48BF1C90
    echo deb http://repository.spotify.com stable non-free | sudo tee /etc/apt/sources.list.d/spotify.list
    sudo apt-get update
    sudo apt-get install spotify-client
    echo "${GREEN}Installed Spotify.${RESET}"
fi

read -p "${BOLD}${UNDERLINE}Install Steam, Minecraft, and Lutris? (y/N)${RESET} " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    echo "${YELLOW}Installing Steam...${RESET}"
    sudo apt install steam
    echo "${GREEN}Installed Steam.${RESET}"
    echo "${YELLOW}Installing Minecraft...${RESET}"
    curl -L https://launcher.mojang.com/download/Minecraft.deb -o ~/Downloads/minecraft.deb
    sudo apt install ~/Downloads/minecraft.deb
    echo "${GREEN}Installed Minecraft.${RESET}"
    echo "${YELLOW}Installing Lutris...${RESET}"
    sudo add-apt-repository ppa:lutris-team/lutris -y
    sudo apt install lutris
    echo "${GREEN}Installed Lutris.${RESET}"
fi

# Note that this installs pip for python3 under `pip` instead of `pip3`.
read -p "${BOLD}${UNDERLINE}Install Pip and Python3 development tools? (y/N)${RESET} " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    echo "Checking for pip...${RESET}"
    if [ ! -f "$(command -v pip)" ]; then
        echo "Pip not installed. Installing Pip..."
        curl https://bootstrap.pypa.io/get-pip.py -o ~/Downloads/get-pip.py
        read -p "${BOLD}${UNDERLINE}Install Pip as user? (y/N)${RESET} " -n 1 -r
        echo

        # The get-pip.py script requires python3-distutils.
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            python3 ~/Downloads/get-pip.py --user
        else
            sudo -H python3 ~/Downloads/get-pip.py
        fi
        echo "${GREEN}Installed Pip $(pip --version)${RESET}"
    else
        echo "${GREEN}Found Pip $(pip --version)${RESET}"
    fi

    read -p "${BOLD}${UNDERLINE}Install Python development packages for $(pip --version | grep -o '(.*)')? (y/N)${RESET} " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        echo "${YELLOW}Installing Python development packages without a virtualenv...${RESET}"
        # These packages are required by e.g., ~/.local/bin/notes and VS Code Python config.
        pip install --upgrade --user virtualenv pygments ipython parsedatetime pylint pydocstyle black jupyter jupyterlab nb-pdf-template nbstripout
        python3 -m nb_pdf_template.install
        mkdir -p ~/.jupyter
        echo "c.LatexExporter.template_file = 'classicm'" >> ~/.jupyter/jupyter_nbconvert_config.py
        echo "c.LatexExporter.template_file = 'classicm'" >> ~/.jupyter/jupyter_notebook_config.py
        # https://github.com/t-makaro/nb_pdf_template
        # https://github.com/ryantam626/jupyterlab_code_formatter
        echo "${BOLD}${RED}Install all other packages in a virtualenv!${RESET}"
        echo "${BOLD}${RED}Use 'python3 -m ipykernel install --user --name=<kernel name>' to install the current venv as a Jupyter kernel."
        echo "${GREEN}Installed Python development packages.${RESET}"
    fi
fi

read -p "${BOLD}${UNDERLINE}Install Gnome Shell extensions? (y/N)${RESET} " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    echo "${YELLOW}Opening Gnome Shell extensions in the default browser...${RESET}"
    xdg-open https://extensions.gnome.org/extension/1319/gsconnect/
    xdg-open https://extensions.gnome.org/extension/1485/workspace-matrix/
    echo "${BOLD}${RED}Install the ${WHITE}gsconnect${RED} and ${WHITE}workspace-matrix${RED} extensions before proceeding.${RESET}"
fi

read -p "${BOLD}${UNDERLINE}Configure system settings? (y/N)${RESET} " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    echo "${YELLOW}Configuring system settings...${RESET}"
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
    echo "${GREEN}Configured system settings.${RESET}"

    echo "${YELLOW}Configuring Gnome tweaks...${RESET}"
    gsettings set org.gnome.desktop.wm.preferences focus-mode 'sloppy'
    gsettings set org.gnome.desktop.interface icon-theme 'Numix-Circle'
    gsettings set org.gnome.desktop.interface gtk-theme 'Yaru-dark'
    gsettings set org.gnome.desktop.interface clock-show-weekday true
    gsettings set org.gnome.shell.extensions.desktop-icons show-trash false
    gsettings set org.gnome.shell.extensions.desktop-icons show-home false
    gsettings set org.gnome.mutter workspaces-only-on-primary false
    echo "${GREEN}Configured Gnome tweaks.${RESET}"
fi

read -p "${BOLD}${UNDERLINE}Configure /etc/fstab for NAS? (y/N)${RESET} " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    NAS_STATIC_IP=192.168.1.112
    sudo mkdir -p /mnt/{assets,documents,images,plex,projects}
    read -p "${BOLD}${UNDERLINE}Attempt to automount NAS? (y/N)${RESET} " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        echo "${GREEN}Adding automount settings to /etc/fstab...${RESET}"
        echo "# Synology NAS NFS shares
${NAS_STATIC_IP}:/volume1/ASSETS       /mnt/assets      nfs defaults 0 0
${NAS_STATIC_IP}:/volume1/DOCUMENTS    /mnt/documents   nfs defaults 0 0
${NAS_STATIC_IP}:/volume1/IMAGES       /mnt/images      nfs defaults 0 0
${NAS_STATIC_IP}:/volume1/PLEX         /mnt/plex        nfs defaults 0 0
${NAS_STATIC_IP}:/volume1/PROJECTS     /mnt/projects    nfs defaults 0 0" | sudo tee -a /etc/fstab
    else
        echo "${GREEN}Adding noauto settings to /etc/fstab...${RESET}"
        echo "# Synology NAS NFS shares. Note that this is a laptop, and these are local
# IPs. Also note that noauto means they won't be mounted on startup.
${NAS_STATIC_IP}:/volume1/ASSETS       /mnt/assets      nfs user,noauto 0 0
${NAS_STATIC_IP}:/volume1/DOCUMENTS    /mnt/documents   nfs user,noauto 0 0
${NAS_STATIC_IP}:/volume1/IMAGES       /mnt/images      nfs user,noauto 0 0
${NAS_STATIC_IP}:/volume1/PLEX         /mnt/plex        nfs user,noauto 0 0
${NAS_STATIC_IP}:/volume1/PROJECTS     /mnt/projects    nfs user,noauto 0 0" | sudo tee -a /etc/fstab
    fi
fi

read -p "${BOLD}${UNDERLINE}Insult on bad sudo password? (y/N)${RESET} " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    echo "${YELLOW}Adding ${WHITE}Defaults    insults${YELLOW} to /etc/sudoers...${RESET}"
    echo "Defaults    insults" | sudo tee -a /etc/sudoers >/dev/null
    echo "${GREEN}Added to /etc/sudoers${RESET}"
fi

echo "${GREEN}Done configuring system.${RESET}"
