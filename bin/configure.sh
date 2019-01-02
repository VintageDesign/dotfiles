#!/usr/bin/env bash
set -o errexit
set -o pipefail
set -o nounset
##############################
# TODO: Do not hard code paths
##############################


read -p "Update dotfiles and vim plugins? (y/N) " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    echo "Updating dotfiles and plugins..."
    # TODO: Avoid hardcoding this path!
    ( cd ~/.config/dotfiles && git pull && git submodule update --remote --recursive --init )
fi

read -p "Install fzf? (y/N) " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    echo "Installing fzf..."
    ~/.fzf/install
    echo "Done installing fzf"
fi

read -p "Install git, vim, and curl? (y/N) " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    echo "Installing git, vim, and curl..."
    sudo apt install git vim curl
fi

read -p "Install Java? (y/N) " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    echo "Adding Java repository and installing Java..."
    sudo add-apt-repository ppa:webupd8team/java -y
    sudo apt update
    sudo apt install oracle-java8-installer
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
    sudo apt install gcc g++ clang clang-format clang-tidy gdb valgrind make cmake shellcheck doxygen graphviz python3-dev optipng
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
    curl -L https://go.microsoft.com/fwlink/?LinkID=760868 -o code.deb
    sudo apt install ./code.deb
    code --install-extension shan.code-settings-sync
    echo "See: https://marketplace.visualstudio.com/items?itemName=Shan.code-settings-sync"
fi

# Note that this installs pip for python3 under `pip` instead of `pip3`.
read -p "Install Pip and Python3 development tools? (y/N) " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    echo "Checking for pip..."
    if [ ! -f "$(which pip)" ]; then
        echo "Pip not installed. Installing Pip..."
        curl https://bootstrap.pypa.io/get-pip.py -o get-pip.py
        read -p "Install Pip as user? (y/N) " -n 1 -r
        echo
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            python3 get-pip.py --user
        else
            sudo -H python3 get-pip.py
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
        pip install --upgrade --user pylint pycodestyle pydocstyle nose black virtualenv pygments ipython jupyter jupyterlab parsedatetime parse-torrent-name nbstripout nb_pdf_template
        # Configure jupyter LaTeX theme for nbconvert, making sure that lines will
        # wrap in a code block.
        python3 -m nb_pdf_template.install --minted
        mkdir -p ~/.jupyter
        # This is the only customization I make to ~/.jupyter/jupyter_nbconvert_config.py
        # so it's safe to completely overwrite the file if it already exists.
        echo "c.PDFExporter.latex_command = ['xelatex', '-8bit', '-shell-escape','{filename}']" > ~/.jupyter/jupyter_nbconvert_config.py
        echo "c.LatexExporter.template_file = 'classicm'" >> ~/.jupyter/jupyter_nbconvert_config.py

        echo "Install all other packages in a virtualenv!"
    fi
fi

read -p "Update and upgrade? (y/N) " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    echo "Installing System Upgrades..."
    sudo apt update && sudo apt upgrade
    sudo apt autoremove && sudo apt autoclean
fi
