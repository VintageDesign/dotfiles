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
cd ~/.vim

git submodule add https://github.com/flazz/vim-colorschemes.git bundle/colorschemes
git submodule add https://github.com/tpope/vim-sensible.git bundle/sensible
git submodule add https://github.com/scrooloose/nerdtree.git bundle/nerdtree
git submodule add https://github.com/tpope/vim-commentary.git bundle/commentary

cd ~

git submodule update --remote

