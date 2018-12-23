#!/usr/bin/env bash
set -o errexit
set -o pipefail
set -o nounset
##############################
# TODO: Do not hard code paths
# TODO: List out programs to install instead of descriptions
##############################


read -p "Update dotfiles and vim plugins? (y/N) " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    echo "Updating dotfiles and plugins..."
    # TODO: Avoid hardcoding this path!
    cd ~/.config/dotfiles
    git pull && git submodule update --remote --recursive --init
    cd -
fi

read -p "Install fzf? (y/N) " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    echo "Installing fzf"
    ~/.fzf/install
    echo "Done installing fzf"
fi

read -p "Install git, vim, and curl? (y/N) " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    echo "Installing Essentials..."
    sudo apt install git vim curl
fi

read -p "Install Java? (y/N) " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    echo "Adding Repositories..."
    sudo add-apt-repository ppa:webupd8team/java -y
    sudo apt update
    sudo apt install oracle-java8-installer
fi

read -p "Install LaTeX? (y/N) " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    echo "Installing texlive, chktex..."
    sudo apt install texlive-full chktex pdf2svg pandoc
fi

read -p "Install dev packages? (y/N) " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    echo "Installing dev packages..."
    sudo apt install gcc g++ clang clang-format clang-tidy gdb make shellcheck doxygen graphviz texlive-full chktex pdf2svg pandoc python3-dev
fi

read -p "Install useful utilities? (y/N) " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    echo "Installing utilities...."
    sudo apt install htop nmap traceroute screen screenfetch linux-tools-common linux-tools-generic openssh-server tree iperf net-tools nfs-common pv
fi

read -p "Install customizations? (y/N) " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    sudo add-apt-repository ppa:numix/ppa -y
    sudo add-apt-repository ppa:mikhailnov/pulseeffects -y
    sudo apt install gnome-tweak-tool chrome-gnome-shell numix-gtk-theme numix-icon-theme-circle pulseeffects
fi

read -p "Install VS Code? (y/N) " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    echo "Installing VS Code and setting-sync"
    curl -L https://go.microsoft.com/fwlink/?LinkID=760868 -o code.deb
    sudo apt install ./code.deb
    code --install-extension shan.code-settings-sync
    echo "See: https://marketplace.visualstudio.com/items?itemName=Shan.code-settings-sync"
fi

read -p "Install python3 dev tools and libraries? (y/N) " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    echo "Checking for pip..."
    if [ ! -f "$(which pip)" ]; then
        echo "Pip not installed. Installing Pip."
        curl https://bootstrap.pypa.io/get-pip.py -o get-pip.py
        read -p "Install Pip as user? (y/N) " -n 1 -r
        echo
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            python3 get-pip.py --user
        else
            sudo -H python3 get-pip.py
        fi
    else
        echo "Found Pip $(pip --version)"
    fi

    echo "Installing commonly used packages as user."
    pip install --upgrade --user pylint pycodestyle pydocstyle nose black virtualenv pygments matplotlib sympy scipy numpy pandas seaborn ipython jupyter jupyterlab parsedatetime nbstripout
fi

read -p "Update and upgrade? (y/N) " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    echo "Installing System Upgrades..."
    sudo apt update && sudo apt upgrade
    sudo apt autoremove && sudo apt autoclean
fi
