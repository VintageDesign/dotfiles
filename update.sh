#!/bin/bash

# Unpack everything into ~/

echo "Unpacking into $HOME"
shopt -s dotglob
mv * ~/ 
cd ~
rm -rf dotfiles

# pull repositories in .vim/bundle/
echo "Downloading vim bundles to $HOME/.vim/bundle/"
mkdir -p ~/.vim/bundle/
cd ~/.vim/bundle/

# TODO: Only clone if they do not already exist, otherwise pull.
git clone https://github.com/tpope/vim-sensible.git
git clone https://github.com/scrooloose/nerdtree.git
git clone git://github.com/tpope/vim-commentary.git
cd ~

