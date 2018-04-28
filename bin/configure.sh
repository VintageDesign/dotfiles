#!/usr/bin/env bash
set -o errexit
set -o pipefail
set -o nounset
##############################
# TODO: Do not hard code paths
##############################

# Install essential commands - no system is complete without them.
read -p "Install git, vim, and unp? (y/N) " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    echo "Installing Essentials..."
    sudo apt install git vim unp htop
fi

# Update dotfiles and vim plugins
read -p "Update dotfiles and vim plugins? (y/N) " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    echo "Updating dotfiles and plugins..."
    # TODO: Avoid hardcoding this!
    cd ~/.config/dotfiles
    git pull && git submodule update --remote --recursive --init
    cd -
fi

# Add Atom and Oracle Java repositories
read -p "Add Java repository? (y/N) " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
	echo "Adding Repositories..."
	# sudo add-apt-repository ppa:webupd8team/atom
	sudo add-apt-repository ppa:webupd8team/java
    sudo apt update
fi

# After adding the repositories, install Java?
read -p "Install Java? (y/N) " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    echo "Installing Java..."
    # TODO: make minecraft work nicely with java9
    sudo apt install oracle-java8-installer
fi

# Install LaTeX?
read -p "Install LaTeX and related? (y/N) " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    echo "Installing texlive, chktex..."
    # TODO: Don't install texmaker from repository -- out of date?
    sudo apt install texlive-full chktex pdf2svg pandoc
fi

# Install dev packages
read -p "Install dev packages? (y/N) " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    echo "Installing dev packages..."
    sudo apt install gcc g++ make clang shellcheck gdb pep8 libcppunit-dev astyle doxygen python3-setuptools pv
    # TODO: this throws an exception relating to the setuptools version
    # sudo easy_install3 pip
    sudo -H pip install --upgrade pip pylint
fi

# Install useful packages
read -p "Install useful utilities? (y/N) " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
	echo "Installing headless Packages...."
	sudo apt install traceroute nmap htop screen screenfetch linux-tools-common linux-tools-generic openssh-server tree iperf
fi

# Install gui packages?
read -p "Install GUI packages? (y/N) " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    # printer-driver-escpr isn't a GUI package, but you only use it on a non-headless system
    sudo apt install pithos printer-driver-escpr gnome-tweak-tool
fi

# Install useful Python 3 packages
read -p "Install python3 scipy stack? (y/N) " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
	echo "Installing Python Packages..."
    sudo -H pip install --upgrade pygments ipython matplotlib sympy scipy numpy networkx nmap pandas seaborn
fi

# Install Jupyter
read -p "Install Jupyter? (y/N) " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
	echo "Installing Jupyter..."
	sudo -H pip install --upgrade jupyter ipython jupyterlab
fi

# Install Jekyll
read -p "Install Jekyll? (y/N) " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    echo "Installing Jekyll..."
    sudo apt install ruby ruby-dev gcc make
    sudo gem install jekyll bundler jekyll-sitemap
fi

# Update and upgrade system
read -p "Update and upgrade? (y/N) " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
	echo "Installing System Upgrades..."
	sudo apt update && sudo apt upgrade
	sudo apt autoremove && sudo apt autoclean
fi

# TODO: setup [s]ftp server on limbo to serve assets?
#       * what to do when updating/configuring limbo?

# TODO: configure fonts
# sudo cp assets/Fonts/Meslo/MesloLGSDZ-Regular.ttf /usr/share/fonts/
# sudo cp assets/Fonts/Apple\ San\ Fransisco/SystemSanFranciscoDisplayBold.ttf assets/Fonts/Apple\ San\ Fransisco/SystemSanFranciscoDisplayRegular.ttf /usr/share/fonts/
#
# sudo fc-cache -fv

# TODO: setup minecraft.desktop and startup script(s)

# TODO: setup terminal profile(s)?

# TODO: setup system preferences

# TODO: setup /etc/hosts

# TODO: setup ~/.ssh/config

# TODO: setup SDSMT VPN

# TODO: Install, configure, and customize CSS for workspace-grid gnome extension
