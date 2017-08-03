#!/bin/bash

# Unpack everything into ~/

# TODO: Decide on whether dotfiles/ will persist in ~/ and perform dotfile udpates with a script, or unpack everything into ~/ and then delete dotfiles/.
echo "Unpacking into $HOME"
shopt -s dotglob
cp -r * ~/ 
cd ~

# pull repositories in .vim/bundle/
echo "Downloading vim bundles to $HOME/.vim/bundle/"
mkdir -p ~/.vim/bundle/
cd ~/.vim/bundle/

# TODO: Only clone if they do not already exist, otherwise pull.
git clone https://github.com/tpope/vim-sensible.git
git clone https://github.com/scrooloose/nerdtree.git
cd ~

