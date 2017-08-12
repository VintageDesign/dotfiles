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

cd ~

git submodule update --remote

