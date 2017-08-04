#!/bin/bash

# Unpack everything into ~/
directory=${PWD##*/}
location=${PWD}
# First run from inside dotfiles
if [ "$directory" == "dotfiles" ]; then
	echo "Unpacking repository into $HOME"
	shopt -s dotglob
	mv ./* ~/
	cd ~
	rm -rf "$location"
fi

# Pull vim plugin repositories in .vim/bundle/
mkdir -p ~/.vim/bundle/
cd ~/.vim/bundle/

echo "Updating vim-sensible"
if [ ! -d "$HOME/.vim/bundle/vim-sensible" ]; then
    git clone https://github.com/tpope/vim-sensible.git
else
    cd vim-sensible && git pull && cd ..
fi
echo "Updating nerdtree"
if [ ! -d "$HOME/.vim/bundle/nerdtree" ]; then
    git clone https://github.com/tpope/nerdtree.git
else
    cd nerdtree && git pull && cd ..
fi
echo "Updating vim-commentary"
if [ ! -d "$HOME/.vim/bundle/vim-commentary" ]; then
    git clone https://github.com/tpope/vim-commentary.git
else
    cd vim-commentary && git pull && cd ..
fi

cd ~
