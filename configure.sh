#!/bin/bash

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

# Clone dotfiles repository if script is being ran from a flash drive
read -p "Clone dotfiles repository to $HOME/dotfiles/? (y/N) " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    echo "Cloning dotfiles repository..."
    git clone https://github.com/Notgnoshi/dotfiles.git ~/dotfiles
fi

# Unpack dotfiles into $HOME. Will fail if $HOME is already a git repository.
read -p "Unpack $HOME/dotfiles/ into $HOME? (y/N) " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
	echo "Unpacking dotfiles/ into $HOME..."
    if [[ -d "$HOME/dotfiles" ]]; then
        shopt -s dotglob
        mv ~/dotfiles/* ~/
        rm -rf ~/dotfiles/
    fi

	# Create ~/.vim/bundle/ if it doesn't already exist.
    mkdir -p ~/.vim/bundle/

	# Pull/update vim plugin repositories.
	cd ~
	git submodule update --remote --recursive --init
	cd -
fi

# Install fzf, requires the fzf submodule to be initialized and updated
read -p "Install fzf? (y/N) " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    echo "Installing fzf"
    # TODO: pipe `yes` into install script?
    $HOME/.fzf/install
    echo "Done installing fzf"
fi

# Update dotfiles and vim plugins
read -p "Update dotfiles and vim plugins? (y/N) " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    echo "Updating dotfiles and plugins..."
    cd ~
    git pull && git submodule update --remote --recursive --init
    cd -
fi

# Generate SSH key for GitHub
read -p "Generate GitHub SSH key? (y/N) " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    echo "Generating ssh key..."
    ssh-keygen -t rsa -b 4096 -f ~/.ssh/github -C "Notgnoshi@gmail.com"

    # Starts up a new instance of ssh-agent if one is already running...
    echo "Adding key to ssh-agent..."
    eval $(ssh-agent)
    ssh-add ~/.ssh/github

    # Creating an SSH key does nothing if it's not added to the account...
    echo
    echo "==============================================="
    echo "Be sure to add SSH key to GitHub account       "
    echo "https://github.com/settings/keys               "
    echo "==============================================="
    echo
    echo "SSH public key:"
    cat ~/.ssh/github.pub
    echo
    echo "Add ~/.ssh/config entry?"
    echo
fi

# Dotfiles reposiroty was cloned with HTTPS, so convert to SSH after SSH keys have been generated
read -p "Set git repository in $HOME to use SSH? (y/N) " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
	echo "Setting remote URL..."
    cd ~
    git remote set-url origin git@github.com:Notgnoshi/dotfiles.git
    cd -
fi

# Install Google Chrome
read -p "Install Google Chrome? (y/N) " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
	echo "Installing Google Chrome..."
	wget https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb
	sudo dpkg -i --force-depends google-chrome-stable_current_amd64.deb
	sudo apt install -f

	rm google-chrome-stable_current_amd64.deb
fi

# Add Atom and Oracle Java repositories
read -p "Add Atom/Java repositories? (y/N) " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
	echo "Adding Repositories..."
	sudo add-apt-repository ppa:webupd8team/atom
	sudo add-apt-repository ppa:webupd8team/java
fi

# After adding the repositories, install Atom and Java?
read -p "Install Atom and Java? (y/N) " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    echo "Installing Atom and Java..."
    # TODO: make minecraft work nicely with java9
    sudo apt install atom oracle-java8-installer
fi

# Install LaTeX?
read -p "Install LaTeX and related? (y/N) " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    echo "Installing texlive, chktex..."
    # TODO: Don't install texmaker from repository -- out of date?
    sudo apt install texlive-full chktex pdf2svg pandoc texmaker
fi

# Install dev packages
read -p "Install dev packages? (y/N) " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    echo "Installing dev packages..."
    sudo apt install gcc g++ make clang shellcheck gdb pep8 libcppunit-dev astyle doxygen python3-setuptools pv
    sudo easy_install3 pip
    sudo -H pip install --upgrade pip pylint pycodestyle
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
	sudo -H pip install --upgrade jupyter ipython
fi

# Install Jekyll
read -p "Install Jekyll? (y/N) " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    echo "Installing Jekyll..."
    sudo apt install ruby ruby-dev gcc make
    sudo gem install jekyll bundler jekyll-sitemap
fi

# Atom packages
read -p "Install Atom packages? (y/N) " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    # TODO: There are some redundant linters. Pick which one(s) to use. (clang vs gcc, pycodestyle vs pylint vs pep8 vs flake8)
    # TODO: decide if file-watcher is still necessary with the new atom update that provides a file watcher API
	apm install linter linter-chktex linter-gcc linter-pep8 linter-shellcheck intentions busy-signal linter-ui-default autoclose-html autocomplete-python highlight-selected language-latex language-liquid language-viml language-haskell markdown-preview-plus minimap minimap-cursorline minimap-find-and-replace minimap-git-diff minimap-highlight-selected tabs-to-spaces autocomplete-clang file-icons file-watcher highlight-selected gruvbox-plus-syntax pdf-view latex latexer python-autopep8 language-matlab linter-pylint
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

