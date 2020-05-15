#!/bin/bash

# If not running interactively, don't do anything
case $- in
*i*) ;;
*) return ;;
esac

# for setting history length see HISTSIZE and HISTFILESIZE in bash(1)
HISTSIZE=-1
# Save all history
HISTFILESIZE=-1
HISTTIMEFORMAT="%h %d %H:%M:%S "
shopt -s histappend

# check the window size after each command and, if necessary,
# update the values of LINES and COLUMNS.
shopt -s checkwinsize

# make less more friendly for non-text input files, see lesspipe(1)
[ -x /usr/bin/lesspipe ] && eval "$(SHELL=/bin/sh lesspipe)"

# Get the dotfile repository direction by resolving the symlink to ~/.bashrc
SOURCE="${BASH_SOURCE[0]}"
# resolve $SOURCE until the file is no longer a symlink
while [ -h "$SOURCE" ]; do
    DIR="$(cd -P "$(dirname "$SOURCE")" >/dev/null 2>&1 && pwd)"
    SOURCE="$(readlink "$SOURCE")"
    # if $SOURCE was a relative symlink, we need to resolve it relative to the path where the symlink file was located
    [[ $SOURCE != /* ]] && SOURCE="$DIR/$SOURCE"
done
# Exported at the bottom with the rest of the environment variables.
DOTFILES_DIR="$(cd -P "$(dirname "$SOURCE")" >/dev/null 2>&1 && pwd)/.."
DOTFILES_DIR="$(readlink --canonicalize --no-newline "${DOTFILES_DIR}")"

for lib in "${DOTFILES_DIR}/lib/"*.sh; do
    [ -f "$lib" ] && source "$lib"
done

# I keep having problems with my ~/.bash_history getting wiped, so instead of fixing the problem, provide a way to recover.
# Unfortunately, I don't know of a nice way to find new commands and automatically append them to a canonical backup.
# So rely on manual intervention in the case something bad happens.
function __backup_histfile() {
    if [ -f ~/.histlogs/logrotate.conf ]; then
        # Make a backup every time a shell is opened.
        logrotate --force --state ~/.histlogs/logrotate.status ~/.histlogs/logrotate.conf

        latest=$(find ~/.histlogs/ -name "${HISTFILE##*/}.*" | sort -n -t . -k 3 | head -1)
        # Complain loudly if $HISTFILE is smaller than the latest backup.
        if [ ! -f "$latest" ] || [ ! -f "$HISTFILE" ] || [ "$(wc -l <"$HISTFILE")" -lt "$(wc -l <"$latest")" ]; then
            echo "${RED}${BOLD}Something horrible has happened to ${WHITE}${HISTFILE}${RED}...${RESET}"
            wc -l "$HISTFILE" "$latest"
        fi
    fi
}

__backup_histfile

# Prints different escape codes to stdout indicating the exit code of the previous command
# Colors are provided by $DOTFILES_DIR/lib/colors.sh
function __decorate_exit_status() {
    if [ $? -eq 0 ]; then
        echo -en "${WHITE}"
    else
        echo -en "${BOLD}${RED}"
    fi
}

# set variable identifying the chroot you work in (used in the prompt below)
if [ -z "${debian_chroot:-}" ] && [ -r /etc/debian_chroot ]; then
    debian_chroot=$(cat /etc/debian_chroot)
fi

# Determine if connected over ssh.
__ssh_flag=0
if [ -n "$SSH_CLIENT" ] || [ -n "$SSH_TTY" ]; then
    __ssh_flag=1
else
    case $(ps -o comm= -p $PPID) in
    sshd | */sshd) __ssh_flag=1 ;;
    esac
fi

# Set the base $PS1
PS1="\u@\h \[${GREEN}\]\w"
# If connected over SSH, prepend a red (ssh) to the $PS1
if [ $__ssh_flag -eq 1 ]; then
    PS1="\[${BOLD}${RED}\](\[${RESET}${RED}\]ssh\[${BOLD}\]) \[${RESET}\]${PS1}"
fi
# Add the Git branch to the $PS1 if present.
# A space is only added to the end if a branch is present.
PS1="${PS1}\[${BLUE}\]\$(__git_ps1)\[${RESET}\]"
# Append a colored $ to the end of the $PS1 indicating the exit code
PS1="${PS1} \[${WHITE}\]\[\$(__decorate_exit_status)\]\$\[${RESET}\] "
unset __ssh_flag

# If this is an xterm set the title to user@host:dir
case "$TERM" in
xterm* | rxvt*)
    # Prepends title thingy to $PS1
    PS1="\[\e]0;${debian_chroot:+($debian_chroot)}\u@\h: \w\a\]$PS1"
    ;;
*) ;;
esac

# enable programmable completion features
if ! shopt -oq posix; then
    if [ -f /usr/share/bash-completion/bash_completion ]; then
        . /usr/share/bash-completion/bash_completion
    elif [ -f /etc/bash_completion ]; then
        . /etc/bash_completion
    fi
    if [ ! -d ~/.bash-completion.d ]; then
        mkdir -p ~/.bash-completion.d
    fi
    for completion_file in ~/.bash-completion.d/*; do
        [ -f "$completion_file" ] && source "$completion_file"
    done
    # TODO: Find the right way to do this.
    if [ -f /usr/lib/llvm-8/share/clang/bash-autocomplete.sh ]; then
        . /usr/lib/llvm-8/share/clang/bash-autocomplete.sh
    fi
    if [ -f /usr/lib/llvm-9/share/clang/bash-autocomplete.sh ]; then
        . /usr/lib/llvm-9/share/clang/bash-autocomplete.sh
    fi
fi

# If tab complete is abimguous, show completions on first <TAB>, not second.
bind 'set show-all-if-ambiguous on'
# Cycle through completions with <TAB>. TODO: Color completions?
bind 'TAB:menu-complete'
# Wait till second <TAB> to complete, list completions on first <TAB>.
bind 'set menu-complete-display-prefix on'
# Tab complete trailing slash for symlinked directories.
bind 'set mark-symlinked-directories on'

# Enable fzf
[ -f ~/.fzf.bash ] && source ~/.fzf.bash

# fzf settings
export FZF_DEFAULT_OPTS="--history-size=10000"
export FZF_ALT_C_OPTS="--preview 'tree -C {} | head -200'"
export FZF_CTRL_T_OPTS="--preview 'tree -C {} | head -200'"

##################################################################################################
# Path settings
##################################################################################################

# Add ~/.local/bin/ to PATH
PATH="$HOME/.local/bin${PATH:+:${PATH}}"
PATH="$HOME/.poetry/bin${PATH:+:${PATH}}"

# Add local manpages, but be sure to not overwrite the defaults
MANPATH="$(manpath --quiet)"
MANPATH="$HOME/.local/man${MANPATH:+:${MANPATH}}"
MANPATH="$HOME/.local/share/man${MANPATH:+:${MANPATH}}"

# A the user-defined CUDA installation to paths.
# The default CUDA installation directory is /usr/local/cuda-xx.y/. But if there are multiple installations
# available, symlink the desired installation to ~/.local/cuda/.
PATH="$HOME/.local/cuda/bin${PATH:+:${PATH}}"
LIBRARY_PATH="$HOME/.local/cuda/lib64${LIBRARY_PATH:+:${LIBRARY_PATH}}"

# Add local header files to gcc include path
CPATH="$HOME/.local/include${CPATH:+:${CPATH}}"
# Add ncurses on the Opp Lab machines
CPATH="$HOME/.local/include/ncursesw${CPATH:+:${CPATH}}"

# Add local libraries to library path.
LIBRARY_PATH="$HOME/.local/lib${LIBRARY_PATH:+:${LIBRARY_PATH}}"

# Setting LIBRARY_PATH is for linking, setting LD_LIBRARY_PATH is for running
LD_LIBRARY_PATH="$LIBRARY_PATH"

export PATH
export CPATH
export LIBRARY_PATH
export LD_LIBRARY_PATH
export MANPATH
export DOTFILES_DIR

# I don't know how I've managed this long without doing this?
export EDITOR=vim
# Path to my vimwiki clone
export VIMWIKI_PATH="$HOME/Documents/notes/"
# Fix less not rendering control characters with git-log on the Opp lab machines.
export LESS=FRX

# Use parallel make by default
export MAKEFLAGS="-j$(nproc)"

# For using XMing on WSL
# export DISPLAY=:0
# export TERM=xterm-256color

# Prevent games from minimizing when focus is lost.
# Steam doesn't read your bashrc. This variable needs to be set through the game options.
export SDL_VIDEO_MINIMIZE_ON_FOCUS_LOSS=0
