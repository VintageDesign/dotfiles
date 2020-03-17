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
DOTFILES_DIR="$(cd -P "$(dirname "$SOURCE")" >/dev/null 2>&1 && pwd)/.."
DOTFILES_DIR="$(readlink --canonicalize --no-newline "${DOTFILES_DIR}")"
echo "Found configuration directory: ${DOTFILES_DIR}"

source "${DOTFILES_DIR}/lib/colors.sh"

read -p "${BOLD}${UNDERLINE}Update dotfiles and vim plugins? (y/N)${RESET} " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    echo "${YELLOW}Updating dotfiles and plugins...${RESET}"
    (cd "${DOTFILES_DIR}" && git pull && git submodule update --remote --recursive --init)
    echo "${GREEN}Updated dotfiles and plugins.${RESET}"
fi

read -p "${BOLD}${UNDERLINE}Install git, vim, and curl? (y/N)${RESET} " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    echo "${YELLOW}Installing git, vim, and curl...${RESET}"
    sudo apt install git vim curl
    echo "${GREEN}Installed git, vim, and curl.${RESET}"
fi

read -p "${BOLD}${UNDERLINE}Install fzf? (y/N)${RESET} " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    echo "${YELLOW}Installing fzf...${RESET}"
    "${DOTFILES_DIR}/.vim/bundle/fzf/install" --all
    echo "${GREEN}Installed fzf.${RESET}"
fi

read -p "${BOLD}${UNDERLINE}Install shellcheck and shfmt? (y/N)${RESET} " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    echo "${YELLOW}Installing shellcheck...${RESET}"
    export scversion="latest"
    curl -L "https://storage.googleapis.com/shellcheck/shellcheck-${scversion}.linux.x86_64.tar.xz" -o /tmp/shellcheck.tar.xz
    tar -xJf /tmp/shellcheck.tar.xz --directory /tmp/
    cp /tmp/shellcheck-"${scversion}"/shellcheck ~/.local/bin/
    chmod +x ~/.local/bin/shellcheck
    echo "${GREEN}Installed shellcheck version:${RESET}"
    shellcheck --version
    echo
    echo "${YELLOW}Installing shmft...${RESET}"
    curl -L https://github.com/mvdan/sh/releases/download/v3.0.1/shfmt_v3.0.1_linux_amd64 -o /tmp/shfmt
    cp /tmp/shfmt ~/.local/bin/
    chmod +x ~/.local/bin/shfmt
    echo "${GREEN}Installed shellcheck version: $(shfmt --version)${RESET}"
fi

read -p "${BOLD}${UNDERLINE}Install LaTeX? (y/N)${RESET} " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    echo "${YELLOW}Installing texlive, chktex, pdf2svg, and pandoc...${RESET}"
    sudo apt install texlive-full chktex pdf2svg pandoc inkscape
    echo "${GREEN}Installed texlive, chktex, pdf2svg, and pandoc.${RESET}"
fi

read -p "${BOLD}${UNDERLINE}Install dev packages? (y/N)${RESET} " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    echo "${YELLOW}Installing dev packages...${RESET}"
    sudo apt install gcc g++ clang clang-format clang-tidy gdb valgrind make cmake doxygen graphviz python3-dev python3-distutils optipng xclip
    echo "${GREEN}Installed dev packages.${RESET}"
fi

# Note that this installs pip for python3 under `pip` instead of `pip3`.
read -p "${BOLD}${UNDERLINE}Install Pip and Python3 development tools? (y/N)${RESET} " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    echo "Checking for pip...${RESET}"
    if [ ! -f "$(command -v pip)" ]; then
        echo "Pip not installed. Installing Pip..."
        curl https://bootstrap.pypa.io/get-pip.py -o /tmp/get-pip.py
        read -p "${BOLD}${UNDERLINE}Install Pip as user? (y/N)${RESET} " -n 1 -r
        echo

        # The get-pip.py script requires python3-distutils.
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            python3 /tmp/get-pip.py --user
        else
            sudo -H python3 /tmp/get-pip.py
        fi
        echo "${GREEN}Installed Pip $(pip --version)${RESET}"
    else
        echo "${GREEN}Found Pip $(pip --version)${RESET}"
    fi

    read -p "${BOLD}${UNDERLINE}Install Python development packages for $(pip --version | grep -o '(.*)')? (y/N)${RESET} " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        echo "${YELLOW}Installing Python development packages without a virtualenv...${RESET}"
        # These packages are necessary to be installed system-wide.
        pip install --upgrade --user --requirement "${DOTFILES_DIR}/requirements.txt"
        python3 -m nb_pdf_template.install
        mkdir -p ~/.jupyter

        # TODO: Don't add these lines if they already exist.
        echo "c.LatexExporter.template_file = 'classicm'" >>~/.jupyter/jupyter_nbconvert_config.py
        {
            echo "c.LatexExporter.template_file = 'classicm'"
            echo "c.NotebookApp.contents_manager_class = 'jupytext.TextFileContentsManager'"
            echo 'c.ContentsManager.default_jupytext_formats = "ipynb,md"'
        } >>~/.jupyter/jupyter_notebook_config.py

        # https://github.com/t-makaro/nb_pdf_template
        # https://github.com/ryantam626/jupyterlab_code_formatter
        # https://github.com/mwouts/jupytext

        jupyter nbextension install --user --py jupytext
        jupyter nbextension enable jupytext --user --py
        # TODO: Configure <ctrl-shift-I> to format cells
        # TODO: Configure 100-column limit
        jupyter labextension install @ryantam626/jupyterlab_code_formatter
        jupyter serverextension enable --user --py jupyterlab_code_formatter
        # TODO: This requires nodejs and npm
        # jupyter lab build
        echo "${BOLD}${RED}Install all other packages in a virtualenv!${RESET}"
        echo "${BOLD}${RED}Use 'python3 -m ipykernel install --user --name=<kernel name>' to install the current venv as a Jupyter kernel."
        echo "${GREEN}Installed Python development packages.${RESET}"
    fi
fi

read -p "${BOLD}${UNDERLINE}Install useful utilities? (y/N)${RESET} " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    echo "${YELLOW}Installing utilities....${RESET}"
    sudo apt install htop nmap traceroute screen screenfetch linux-tools-common linux-tools-generic openssh-server tree iperf net-tools nfs-common pv
    echo "${GREEN}Installed utilities.${RESET}"
fi

read -p "${BOLD}${UNDERLINE}Install VS Code? (y/N)${RESET} " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    echo "${YELLOW}Installing VS Code and setting-sync...${RESET}"
    curl -L https://go.microsoft.com/fwlink/?LinkID=760868 -o /tmp/code.deb
    sudo apt install /tmp/code.deb
    code --install-extension shan.code-settings-sync
    echo "${BOLD}${RED}See: https://marketplace.visualstudio.com/items?itemName=Shan.code-settings-sync${RESET}"
    echo "${GREEN}Installed VS Code and settings-sync.${RESET}"
fi

read -p "${BOLD}${UNDERLINE}Install Discord and Spotify? (y/N)${RESET} " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    echo "${YELLOW}Installing Discord...${RESET}"
    curl -L "https://discordapp.com/api/download?platform=linux&format=deb" -o /tmp/discord.deb
    sudo apt install /tmp/discord.deb
    echo "${GREEN}Installed Discord.${RESET}"
    echo "${YELLOW}Installing Spotify...${RESET}"
    # I kept having to reinstall the debian package to fix some issues.
    sudo snap install spotify
    echo "${GREEN}Installed Spotify.${RESET}"
fi

read -p "${BOLD}${UNDERLINE}Install Minecraft? (y/N)${RESET} " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    echo "${YELLOW}Installing Minecraft...${RESET}"
    curl -L https://launcher.mojang.com/download/Minecraft.deb -o /tmp/minecraft.deb
    sudo apt install /tmp/minecraft.deb
    echo "${GREEN}Installed Minecraft.${RESET}"
fi

read -p "${BOLD}${UNDERLINE}Install Steam, and Lutris? (y/N)${RESET} " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    echo "${YELLOW}Installing Steam...${RESET}"
    sudo apt install steam
    echo "${GREEN}Installed Steam.${RESET}"
    echo "${YELLOW}Installing Lutris...${RESET}"
    sudo add-apt-repository ppa:lutris-team/lutris -y
    sudo apt install lutris
    echo "${GREEN}Installed Lutris.${RESET}"
fi

read -p "${BOLD}${UNDERLINE}Install Gnome tweaks? (y/N)${RESET} " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    echo "${YELLOW}Installing tweaks...${RESET}"
    sudo add-apt-repository ppa:numix/ppa -y
    sudo apt install gnome-tweak-tool chrome-gnome-shell numix-gtk-theme numix-icon-theme-circle
    echo "${GREEN}Installed tweaks.${RESET}"
fi

read -p "${BOLD}${UNDERLINE}Install Gnome Shell extensions? (y/N)${RESET} " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    echo "${YELLOW}Opening Gnome Shell extensions in the default browser...${RESET}"
    xdg-open https://extensions.gnome.org/extension/1319/gsconnect/
    xdg-open https://extensions.gnome.org/extension/1485/workspace-matrix/
    xdg-open https://extensions.gnome.org/extension/921/multi-monitors-add-on/
    xdg-open https://extensions.gnome.org/extension/104/netspeed/
    echo "${BOLD}${RED}Install the ${WHITE}gsconnect${RED}, ${WHITE}workspace-matrix${RED}, ${WHITE}netspeed${RED}, and ${WHITE}multi-monitors-add-on${RED} extensions before proceeding.${RESET}"
fi

read -p "${BOLD}${UNDERLINE}Configure system settings? (y/N)${RESET} " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    echo "${YELLOW}Configuring system settings...${RESET}"
    gsettings set org.gnome.shell favorite-apps "['firefox.desktop', 'org.gnome.Nautilus.desktop']"
    gsettings set org.gnome.shell.extensions.dash-to-dock show-mounts false
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
    gsettings set org.gnome.shell.extensions.dash-to-dock isolate-workspaces true
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
    NAS_STATIC_IP=192.168.0.123
    # Nautilus integrates better with stuff here.
    MOUNT_ROOT="/media/$USER"
    sudo mkdir -p "$MOUNT_ROOT/"{documents,plex}
    read -p "${BOLD}${UNDERLINE}Attempt to automount NAS? (y/N)${RESET} " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        echo "${GREEN}Adding automount settings to /etc/fstab...${RESET}"
        echo "# Synology NAS NFS shares
${NAS_STATIC_IP}:/volume1/DOCUMENTS    ${MOUNT_ROOT}/documents   nfs users,defaults 0 0
${NAS_STATIC_IP}:/volume1/PLEX         ${MOUNT_ROOT}/plex        nfs users,defaults 0 0" | sudo tee -a /etc/fstab
    else
        echo "${GREEN}Adding noauto settings to /etc/fstab...${RESET}"
        echo "# Synology NAS NFS shares. Note that this is a laptop, and these are local
# IPs. Also note that noauto means they won't be mounted on startup.
${NAS_STATIC_IP}:/volume1/DOCUMENTS    ${MOUNT_ROOT}/documents   nfs users,noauto 0 0
${NAS_STATIC_IP}:/volume1/PLEX         ${MOUNT_ROOT}/plex        nfs users,noauto 0 0" | sudo tee -a /etc/fstab
    fi
fi

read -p "${BOLD}${UNDERLINE}Insult on bad sudo password? (y/N)${RESET} " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    echo "${YELLOW}Adding ${WHITE}Defaults    insults${YELLOW} to /etc/sudoers...${RESET}"
    # NOTE: Bad things happen if you fuck up this line.
    echo "Defaults    insults" | sudo tee -a /etc/sudoers >/dev/null
    echo "${GREEN}Added to /etc/sudoers${RESET}"
fi

echo "${GREEN}Done configuring system.${RESET}"
