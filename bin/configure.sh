#!/usr/bin/env bash
set -o errexit
set -o pipefail
set -o nounset

# Get the location of the dotfiles directory, by finding the location of this script.
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

# Life isn't complete without some colors.
source "${DOTFILES_DIR}/lib/colors.sh"

read -p "${BOLD}${UNDERLINE}Update dotfiles and vim plugins? (y/N)${RESET} " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    echo "${YELLOW}Updating dotfiles and plugins...${RESET}"
    # --remote uses live-at-head strategy.
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
    curl --location --output /tmp/shellcheck.tar.xz "https://github.com/koalaman/shellcheck/releases/download/stable/shellcheck-stable.linux.x86_64.tar.xz"
    tar -xJf /tmp/shellcheck.tar.xz --directory /tmp/
    cp /tmp/shellcheck-stable/shellcheck ~/.local/bin/
    chmod +x ~/.local/bin/shellcheck
    echo "${GREEN}Installed latest shellcheck, version:${RESET}"
    shellcheck --version

    echo "${YELLOW}Installing shfmt...${RESET}"
    # shfmt doesn't have a 'latest' tag, so we find it ourselves.
    USER="mvdan"
    REPO="sh"
    curl --silent "https://api.github.com/repos/$USER/$REPO/releases/latest" | # Get latest release from GitHub api
        grep --only-matching --perl-regexp '"tag_name": "\K(.*)(?=")' |        # Get the latest tag
        xargs -I {} curl --location --output ~/.local/bin/shfmt --remote-name "https://github.com/$USER/$REPO/releases/download/{}/shfmt_{}_linux_amd64"
    chmod +x ~/.local/bin/shfmt
    echo "${GREEN}Installed shfmt version: $(shfmt --version)${RESET}"
fi

read -p "${BOLD}${UNDERLINE}Install Tilix as default terminal? (y/N)${RESET} " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    echo "${YELLOW}Installing Tilix...${RESET}"
    sudo apt install tilix
    sudo update-alternatives --set x-terminal-emulator /usr/bin/tilix.wrapper
    # As per https://askubuntu.com/a/294430, nautilus uses a hard coded list of terminals.
    # The suggested "fix" of removing gnome-terminal and symlinking to tilix doesn't work
    # See https://bugzilla.gnome.org/show_bug.cgi?id=627943 for asinine WONTFIX justifications.
    echo "${YELLOW}Loading profile from dotfiles${RESET}"
    dconf dump /com/gexperts/Tilix/ >"${DOTFILES_DIR}"/tilix.dconf.default
    dconf load /com/gexperts/Tilix/ <"${DOTFILES_DIR}"/tilix.dconf
    echo "${GREEN}Installed Tilix.${RESET}"
fi

read -p "${BOLD}${UNDERLINE}Install LaTeX? (y/N)${RESET} " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    echo "${YELLOW}Installing texlive, chktex, pdf2svg, and pandoc...${RESET}"
    sudo apt install \
        chktex \
        inkscape \
        pandoc \
        pdf2svg \
        texlive-full
    echo "${GREEN}Installed texlive, chktex, pdf2svg, and pandoc.${RESET}"
fi

read -p "${BOLD}${UNDERLINE}Install dev packages? (y/N)${RESET} " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    echo "${YELLOW}Installing dev packages...${RESET}"
    sudo apt install \
        clang \
        clang-format \
        clang-tidy \
        cmake \
        doxygen \
        g++ \
        gcc \
        gdb \
        graphviz \
        make \
        optipng \
        python3-dev \
        python3-distutils \
        valgrind \
        xclip
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

        # https://github.com/t-makaro/nb_pdf_template
        python3 -m nb_pdf_template.install
        mkdir -p ~/.jupyter

        # TODO: Don't add these lines if they already exist.
        echo "c.LatexExporter.template_file = 'classicm'" >>~/.jupyter/jupyter_nbconvert_config.py
        {
            echo "c.LatexExporter.template_file = 'classicm'"
            echo "c.NotebookApp.contents_manager_class = 'jupytext.TextFileContentsManager'"
            echo 'c.ContentsManager.default_jupytext_formats = "ipynb,md"'
        } >>~/.jupyter/jupyter_notebook_config.py

        read -p "${BOLD}${UNDERLINE}Install node.js and npm from package manager? (y/N)${RESET} " -n 1 -r
        echo
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            sudo apt install nodejs npm
        fi
        read -p "${BOLD}${UNDERLINE}Install Jupyter extensions (requires node.js)? (y/N)${RESET} " -n 1 -r
        echo
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            if which node && which npm; then
                # https://github.com/mwouts/jupytext
                jupyter nbextension install --user --py jupytext
                jupyter nbextension enable jupytext --user --py
                # https://github.com/ryantam626/jupyterlab_code_formatter
                # TODO: Configure <ctrl-shift-I> to format cells
                # TODO: Configure 100-column limit
                jupyter labextension install @ryantam626/jupyterlab_code_formatter
                jupyter serverextension enable --user --py jupyterlab_code_formatter
            else
                echo "${BOLD}${RED}node.js not found. Try again.${RESET}"
            fi
        fi
        echo "${BOLD}${RED}Install all other packages in a virtualenv!${RESET}"
        echo "${BOLD}${RED}Use 'python3 -m ipykernel install --user --name=<kernel name>' to install the current venv as a Jupyter kernel."
        echo "${GREEN}Installed Python development packages.${RESET}"
    fi
fi

read -p "${BOLD}${UNDERLINE}Install useful utilities? (y/N)${RESET} " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    echo "${YELLOW}Installing utilities....${RESET}"
    sudo apt install \
        colordiff \
        htop \
        iperf \
        linux-tools-common \
        linux-tools-generic \
        net-tools \
        nfs-common \
        nmap \
        openssh-server \
        pv \
        screen \
        screenfetch \
        traceroute \
        tree
    echo "${GREEN}Installed utilities.${RESET}"
fi

read -p "${BOLD}${UNDERLINE}Install VS Code? (y/N)${RESET} " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    echo "${YELLOW}Installing VS Code and setting-sync...${RESET}"
    curl --location https://go.microsoft.com/fwlink/?LinkID=760868 --output /tmp/code.deb
    sudo apt install /tmp/code.deb
    code --install-extension shan.code-settings-sync
    echo "${BOLD}${RED}See: https://marketplace.visualstudio.com/items?itemName=Shan.code-settings-sync${RESET}"
    echo "${GREEN}Installed VS Code and settings-sync.${RESET}"
fi

read -p "${BOLD}${UNDERLINE}Install Discord and Spotify? (y/N)${RESET} " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    echo "${YELLOW}Installing Discord...${RESET}"
    curl --location "https://discordapp.com/api/download?platform=linux&format=deb" --output /tmp/discord.deb
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
    curl --location https://launcher.mojang.com/download/Minecraft.deb --output /tmp/minecraft.deb
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
    sudo apt install gnome-tweak-tool chrome-gnome-shell numix-gtk-theme numix-icon-theme-circle
    echo "${GREEN}Installed tweaks.${RESET}"
fi

read -p "${BOLD}${UNDERLINE}Install Gnome Shell extensions? (y/N)${RESET} " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    echo "${YELLOW}Opening Gnome Shell extensions in the default browser...${RESET}"
    EXTENSIONS=(
        https://extensions.gnome.org/extension/104/netspeed/
        https://extensions.gnome.org/extension/1166/extension-update-notifier/
        https://extensions.gnome.org/extension/1319/gsconnect/
        https://extensions.gnome.org/extension/1485/workspace-matrix/
        https://extensions.gnome.org/extension/1723/wintile-windows-10-window-tiling-for-gnome/
        https://extensions.gnome.org/extension/708/panel-osd/
        https://extensions.gnome.org/extension/906/sound-output-device-chooser/
        https://extensions.gnome.org/extension/921/multi-monitors-add-on/
    )
    for extension in "${EXTENSIONS[@]}"; do
        xdg-open "$extension"
    done
    echo "${BOLD}${RED}Install Gnome extensions before proceding.${RESET}"
fi

read -p "${UNDERLINE}Configure system settings ${BOLD}(requires extensions)?${RESET}${UNDERLINE} (y/N)${RESET} " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    echo "${YELLOW}Configuring system settings...${RESET}"
    echo "Saving original gsettings to ~/settings.orig"
    if [ ! -f ~/settings.orig ]; then
        gsettings list-recursively >~/settings.orig
    fi
    # Set firefox and Nautilus to be the only apps always shown in the dock.
    gsettings set org.gnome.shell favorite-apps "['firefox.desktop', 'org.gnome.Nautilus.desktop']"
    gsettings set org.gnome.desktop.datetime automatic-timezone true
    gsettings set org.gnome.desktop.interface clock-format '12h'
    gsettings set org.gnome.desktop.notifications show-in-lock-screen false
    # Who in their right mind uses natural scrolling?
    gsettings set org.gnome.desktop.peripherals.touchpad natural-scroll false
    gsettings set org.gnome.desktop.privacy remember-recent-files false
    gsettings set org.gnome.desktop.wm.keybindings move-to-monitor-up "['<Primary><Super>Up']"
    gsettings set org.gnome.desktop.wm.keybindings move-to-monitor-right "['<Primary><Super>Right']"
    gsettings set org.gnome.desktop.wm.keybindings move-to-monitor-left "['<Primary><Super>Left']"
    gsettings set org.gnome.desktop.wm.keybindings move-to-monitor-down "['<Primary><Super>Down']"
    gsettings set org.gnome.settings-daemon.plugins.color night-light-enabled true
    gsettings set org.gnome.settings-daemon.plugins.power ambient-enabled true
    gsettings set org.gnome.settings-daemon.plugins.power sleep-inactive-ac-timeout 3600
    gsettings set org.gnome.settings-daemon.plugins.power sleep-inactive-ac-type 'nothing'
    gsettings set org.gnome.shell disabled-extensions "['desktop-icons@csoriano']"
    gsettings set org.gnome.shell.extensions.dash-to-dock dash-max-icon-size 48
    gsettings set org.gnome.shell.extensions.dash-to-dock show-mounts false
    # Every time, I have to look this up...
    gsettings set org.gnome.shell.extensions.dash-to-dock isolate-workspaces true
    gsettings set org.gtk.Settings.FileChooser clock-format '12h'
    echo "${GREEN}Configured system settings.${RESET}"

    echo "${YELLOW}Configuring Gnome tweaks...${RESET}"
    gsettings set org.gnome.desktop.interface clock-show-weekday true
    gsettings set org.gnome.desktop.interface gtk-theme 'Yaru-dark'
    gsettings set org.gnome.desktop.interface icon-theme 'Numix-Circle'
    # Focus a window by moving the mouse over it.
    gsettings set org.gnome.desktop.wm.preferences focus-mode 'sloppy'
    gsettings set org.gnome.mutter attach-modal-dialogs false
    gsettings set org.gnome.mutter center-new-windows true
    gsettings set org.gnome.mutter dynamic-workspaces false
    gsettings set org.gnome.mutter edge-tiling false
    gsettings set org.gnome.mutter workspaces-only-on-primary false
    gsettings set org.gnome.shell.extensions.desktop-icons show-home false
    gsettings set org.gnome.shell.extensions.desktop-icons show-trash false
    gsettings set org.gnome.shell.overrides edge-tiling false
    gsettings set org.gnome.shell.overrides workspaces-only-on-primary false
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
    # Even worse things happen if you've encrypted your disk.
    echo "Defaults    insults" | sudo tee -a /etc/sudoers >/dev/null
    echo "${GREEN}Added to /etc/sudoers${RESET}"
fi
