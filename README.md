# dotfiles
My personal dotfiles and shell scripts

* Clone repository into `~/`.
* Run `update.sh` to unpack repo into `~/`, delete the repository (must be named `dotfiles`)
    - This will move *all* files to `~/`, including `.git/`, and `.gitignore`, effectively turning your home directory into this repository. 
    - The `.gitignore` file *should* be set up to ignore everything correctly.
    - Run `update.sh` to update the vim plugin repositories, or reclone them if they have been deleted.

## TODO:

* Rename `update.sh` to `unpack.sh`?
* Reduce clutter in `~/`
* Work out a system configuration script that clones and unpacks this repository
* Make `update.sh`/`unpack.sh` more sophisticated...
	- Check for pre-existing Git repository in `~/`
	- Fetch changes
	- If there are local changes, prompt to update master
* Use branches to allow for system-dependent configuration?
* Improve/clean up `.bashrc` and `.bash_aliases`
* Documentation

