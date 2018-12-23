#!/bin/bash

# If not running interactively, don't do anything
case $- in
    *i*) ;;
    *) return;;
esac

# don't put duplicate lines or lines starting with space in the history.
# See bash(1) for more options
HISTCONTROL=ignorebot

# for setting history length see HISTSIZE and HISTFILESIZE in bash(1)
HISTSIZE=5000
HISTFILESIZE=20000

# check the window size after each command and, if necessary,
# update the values of LINES and COLUMNS.
shopt -s checkwinsize

# make less more friendly for non-text input files, see lesspipe(1)
[ -x /usr/bin/lesspipe ] && eval "$(SHELL=/bin/sh lesspipe)"

# set variable identifying the chroot you work in (used in the prompt below)
if [ -z "${debian_chroot:-}" ] && [ -r /etc/debian_chroot ]; then
    debian_chroot=$(cat /etc/debian_chroot)
fi

# set a fancy prompt (non-color, unless we know we "want" color)
case "$TERM" in
    xterm-color) color_prompt=yes;;
esac

force_color_prompt=yes

if [ -n "$force_color_prompt" ]; then
    if [ -x /usr/bin/tput ] && tput setaf 1 >&/dev/null; then
        # We have color support; assume it's compliant with Ecma-48
        # (ISO/IEC-6429). (Lack of such support is extremely rare, and such
        # a case would tend to support setf rather than setaf.)
        color_prompt=yes
    else
        color_prompt=h
    fi
fi

# colored text variables.
export UNDERLINE=$(tput sgr 0 1)
export BOLD=$(tput bold)
export BLACK=$(tput setaf 0)
export RED=$(tput setaf 1)
export GREEN=$(tput setaf 2)
export YELLOW=$(tput setaf 3)
export BLUE=$(tput setaf 4)
export PURPLE=$(tput setaf 5)
export CYAN=$(tput setaf 6)
export WHITE=$(tput setaf 7)
export RESET=$(tput sgr0)

# Prints different escape codes to stdout indicating the exit code of the previous command
decorate_exit_status()
{
    if [ $? -eq 0 ]; then
        echo -e "${WHITE}"
        # echo -e "${BOLD}${GREEN}"
    else
        echo -e "${BOLD}${RED}"
    fi
}

# Determine if connected over ssh.
SSH_FLAG=0
if [ -n "$SSH_CLIENT" ] || [ -n "$SSH_TTY" ]; then
    SSH_FLAG=1
else
    case $(ps -o comm= -p $PPID) in
        sshd|*/sshd) SSH_FLAG=1;;
    esac
fi

if [ "$color_prompt" = yes ]; then
    # Set the base $PS1
    PS1="\u@\h \[${GREEN}\]\w"
    # If connected over SSH, prepend a red (ssh) to the $PS1
    if [ $SSH_FLAG -eq 1 ]; then
        PS1="\[${BOLD}${RED}\](\[${RESET}${RED}\]ssh\[${BOLD}\]) \[${RESET}\]${PS1}"
    fi
    # Append a colored $ to the end of the $PS1 indicating the exit code
    PS1="${PS1}\[\$(decorate_exit_status)\] \$ \[${RESET}\]"
else
    PS1='${debian_chroot:+($debian_chroot)}\u@\h:\w\$ '
fi
unset color_prompt force_color_prompt SSH_FLAG

# If this is an xterm set the title to user@host:dir
case "$TERM" in
    xterm*|rxvt*)
        # Prepends title thingy to $PS1
        PS1="\[\e]0;${debian_chroot:+($debian_chroot)}\u@\h: \w\a\]$PS1"
        ;;
    *)
        ;;
esac

# Enable colored man pages
man() {
    env \
        LESS_TERMCAP_mb="$(printf "\e[1;31m")"    \
        LESS_TERMCAP_md="$(printf "\e[1;31m")"    \
        LESS_TERMCAP_me="$(printf "\e[0m")"       \
        LESS_TERMCAP_se="$(printf "\e[0m")"       \
        LESS_TERMCAP_so="$(printf "\e[1;44;33m")" \
        LESS_TERMCAP_ue="$(printf "\e[0m")"       \
        LESS_TERMCAP_us="$(printf "\e[1;32m")"    \
        man "$@"
}

if [ -f ~/.bash_aliases ]; then
    source ~/.bash_aliases
fi

# enable programmable completion features
if ! shopt -oq posix; then
    if [ -f /usr/share/bash-completion/bash_completion ]; then
        . /usr/share/bash-completion/bash_completion
    elif [ -f /etc/bash_completion ]; then
        . /etc/bash_completion
    fi
fi

# If tab complete is abimguous, show completions on first <TAB>, not second.
bind 'set show-all-if-ambiguous on'
# Cycle through completions with <TAB>. TODO: Color completions?
bind 'TAB:menu-complete'
# Wait till second <TAB> to complete, list completions on first <TAB>.
bind 'set menu-complete-display-prefix on'

# Enable fzf
[ -f ~/.fzf.bash ] && source ~/.fzf.bash

# fzf settings
export FZF_ALT_C_OPTS="--preview 'tree -C {} | head -200'"
export FZF_CTRL_T_OPTS="--preview 'tree -C {} | head -200'"

##################################################################################################
# Path settings
##################################################################################################
# TODO: Make CUDA path work on laptop?
# TODO: Prefer ~/.local/bin/ over ~/bin/

# Add ~/bin/ to path
export PATH="$HOME/bin:$PATH"
# Add locally-installed binaries to path
export PATH="$HOME/.local/bin:$PATH"
# Add CUDA nvcc et al to path on Opp Lab machines.
export PATH="/usr/local/cuda/bin:$PATH"

# Add local header files to gcc path
export CPATH="$HOME/.local/include:$CPATH"

# Add local libraries to path
export LIBRARY_PATH="$LIBRARY_PATH:$HOME/.local/lib"
# Add CUDA libraries to path for use one Opp Lab machines.
export LIBRARY_PATH="$LIBRARY_PATH:/usr/local/cuda/lib64"

# Setting LIBRARY_PATH is for linking, setting LD_LIBRARY_PATH is for running
export LD_LIBRARY_PATH="$LIBRARY_PATH"

# Force Matlab to use Java 8 -- eliminates MEvent. CASE! spam
export MATLAB_JAVA="/usr/lib/jvm/java-8-oracle/jre"

# Use parallel make by default
export MAKEFLAGS="-j$(nproc)"

# For using XMing on WSL
# export DISPLAY=:0
export TERM=xterm-256color

# Source my utility functions
source "$HOME/bin/utils.sh"
