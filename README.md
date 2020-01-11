# dotfiles

My personal dotfiles and shell scripts

---

See [here](https://agill.xyz/ubuntu-configuration/) for how I set up a new Ubuntu system.

**Important:** SSH keys for Git should already be set up before cloning this repository.

```bash
git clone --recurse-submodules git@github.com:Notgnoshi/dotfiles.git ~/.config/dotfiles
~/.config/dotfiles/deploy.py ~
~/.local/bin/configure.sh
source ~/.bashrc
```
