# dotfiles
My personal dotfiles and shell scripts

* Clone repository into `~`.
* Run `update.sh` to unpack repo into `~`, delete the repository (must be named `dotfiles`)
    - This will move *all* files to `~`, including `.git/`, and `.gitignore`, effectively turning your home directory into this repository. 
    - The `.gitignore` file *should* be set up to ignore everything correctly.
    - Run `update.sh` to update the vim plugin repositories, or reclone them if they have been deleted.

