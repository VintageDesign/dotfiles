# dotfiles

My personal dotfiles and shell scripts

---

## Prerequisites

* SSH keys should already be created and configured in GitHub user settings

  ```sh
  ssh-keygen -b 4096
  ```

* Prerequisite packages

  ```sh
  sudo dnf install vim-enhanced stow git curl
  ```

  ```sh
  sudo apt install vim-gtk stow git curl
  ```

## Installation

```bash
git clone --recurse-submodules git@github.com:Notgnoshi/dotfiles.git ~/.config/dotfiles
cd ~/.config/dotfiles
./setup
```
