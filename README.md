# dotfiles

My personal dotfiles and shell scripts

---

See [here](https://agill.xyz/ubuntu-configuration/) for how I set up a new Ubuntu system.

* Clone repository into `~/.config/dotfiles/` using the `--recurse-submodules` flag.

  **Important:** SSH keys for Git should already be set up before cloning this repository.

  ```shell
  git clone --recurse-submodules git@github.com:Notgnoshi/dotfiles.git ~/.config/dotfiles
  ```

* Run `~/.config/dotfiles/deploy.py ~` to deploy dotfiles to home directory. You may have to delete `~/bin/`, `~/.vim/`, `~/.vimrc`, and `~/.fzf/` if they already exist.

  ```shell
  ~/.config/dotfiles/deploy.py ~
  ```

* Run `~/bin/configure.sh` and answer `y` to all prompts as necessary.

  ```shell
  ~/bin/configure.sh
  ```

* Source `~/.bashrc`.

  ```shell
  source ~/.bashrc
  ```

---

## TODO

* Install and configure fonts
* Edit `/etc/hosts`
* Add `~/.ssh/config` and generate SSH keys. But this is required before cloning this repo?
* Terminal profiles
* Ubuntu settings
* `.desktop` files
* Wallpaper
