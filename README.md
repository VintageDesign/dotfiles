# dotfiles

My personal dotfiles and shell scripts

---

See [here](https://agill.xyz/ubuntu-configuration/) for how I use this repository.

* Clone repository into `~/.config/dotfiles/` using the `--recurse-submodules` flag. As of yet this path is hardcoded.
* Run `~/.config/dotfiles/deploy.sh ~` to deploy dotfiles to home directory. You may have to delete `~/bin/`, `~/.vim/`, `~/.vimrc`, and `~/.fzf/` if they already exist.
* Run `~/bin/configure.sh` and answer `y` to all prompts as necessary, especially making sure to update submodules if this is the first run.

---

## TODO

* Install and configure fonts
* Edit `/etc/hosts`
* Add `~/.ssh/config` and generate SSH keys.
* Headless install (no pithos, texmaker, atom, etc)
* Terminal profiles
* Ubuntu settings
* `.desktop` files
* Download Maple and Matlab from (S)FTP server?
* Wallpaper
* Download and install Minecraft and Discord.
* Configure minecraft settings and `.desktop` file and script(s).
