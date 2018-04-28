# dotfiles

My personal dotfiles and shell scripts

---

* Clone repository into `~/.config/dotfiles/`. As of yet this path is hardcoded.
* Run `~/.config/dotfiles/deploy.sh ~` to deploy dotfiles to home directory. You may have to delete `~/bin/`, `~/.vim/`, `~/.vimrc`, and `~/.fzf/`.
* Run `~/bin/configure.sh` and answer `y` to all prompts as necessary, especially making sure to update submodules if this is the first run.

---

## Documentation

Running `~/bin/configure.sh` will prompt for the following:

* Install `git`, `vim`, and `unp`. No system is complete without these essentials
* Update this repository (pull) and vim plugin submodules. Not necessary if immediately preceded by the above step
* Add Oracle Java repository
* Install essential packages. Things like system tools, `gcc`, `g++`, `gdb`, etc
* Install Python (version 3) SciPy stack and related
* Install Jupyter
* Update and upgrade system

---

## TODO

* Import and configure fonts
* Edit `/etc/hosts`
* Add `~/.ssh/config`
* Good way to generate/store ssh keys
* Headless install (no pithos, texmaker, atom, etc)
* Terminal profiles
* Ubuntu settings
* `.desktop` files
* Download Maple and Matlab from (S)FTP server?
* Setup `/etc/hosts`
* Wallpaper
