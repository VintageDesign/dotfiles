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
    # If connected over ssh, say so.
    if [ $SSH_FLAG -eq 1 ]; then
        PS1="\[\e[31m\](ssh)\[\e[0m\] \u@\h \[\e[0m\]\[\e[32m\]\w\[\e[0m\]\[\e[37m\] \\$ \[\e[0m\]"
    else
        PS1="\u@\h \[\e[0m\]\[\e[32m\]\w\[\e[0m\]\[\e[37m\] \\$ \[\e[0m\]"
    fi
else
    PS1='${debian_chroot:+($debian_chroot)}\u@\h:\w\$ '
fi
unset color_prompt force_color_prompt SSH_FLAG

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

# Add ~/bin/ to path
export PATH="$HOME/bin:$PATH"
# Source my utility functions
source "$HOME/bin/utils.sh"
