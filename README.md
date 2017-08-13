# dotfiles
My personal dotfiles and shell scripts

* Clone repository into `~/dotfiles/`
* Run `./configure.sh` and answer `y` to all prompts as necessary

---

## Documentation:
Running `./configure.sh` will prompt for the following:

* Install `git`, `vim`, and `unp`. No system is complete without these essentials
* Clone this repository - useful for keeping this script on a flash drive for emergency Linux installs...
* Unpack the contents of this repository into `~/`, including `.git/` and `.gitignore`. The `.gitignore` file ignores everything but the contents of this repository. Also pulls the vim plugins submodules determined by `.gitmodules`
* Update this repository (pull) and vim plugin submodules. Not necessary if immediately preceded by the above step
* Generate GitHub SSH key. Generates an SSH key and saves it as `~/.ssh/github`. Does not add the SSH key to GitHub account, but gives reminder and link
* Since the script to clone this repository clones it with HTTPS, prompt for setting the remote URL to use SSH. Not done be default to allow for setting up SSH keys
* Install Google Chrome
* Add [Atom](https:atom.io) apt repository and Oracle Java repository
* Install essential packages. Things like system tools, `gcc`, `g++`, `gdb`, etc
* Install Python (version 3) SciPy stack and related
* Install Jupyter
* Install Atom packages
* Update and upgrade system

---

## TODO:
* Reduce `$HOME` clutter?
* Import and configure fonts
* Edit `/etc/hosts`
* Add `~/.ssh/config`
* Good way to generate/store ssh keys

