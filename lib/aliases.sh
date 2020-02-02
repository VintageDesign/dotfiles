#!/bin/bash

alias grep='grep --color=auto'
alias egrep='egrep --color=auto'
alias fgrep='fgrep --color=auto'

alias tree='tree -C'

alias ls='ls -h --color=auto'
alias ll='ls -alF'
alias la='ls -A'
alias l='ls -CF'

alias back="cd -"
alias xo='xdg-open'

alias upd='sudo apt update'
alias upg='sudo apt upgrade'
alias acl='sudo apt-get autoclean'
alias arem='sudo apt-get autoremove'

alias wiki='vim $VIMWIKI_PATH/index.wiki'
alias todo='vim $VIMWIKI_PATH/todo.wiki'
alias journal='vim $VIMWIKI_PATH/diary/diary.wiki'
alias today='vim -c VimwikiMakeDiaryNote'
alias tomorrow='vim -c VimwikiMakeTomorrowDiaryNote'
alias yesterday='vim -c VimwikiMakeYesterdayDiaryNote'

# Enable colored man pages
man() {
    env \
        LESS_TERMCAP_mb="$(printf "\e[1;31m")" \
        LESS_TERMCAP_md="$(printf "\e[1;31m")" \
        LESS_TERMCAP_me="$(printf "\e[0m")" \
        LESS_TERMCAP_se="$(printf "\e[0m")" \
        LESS_TERMCAP_so="$(printf "\e[1;44;33m")" \
        LESS_TERMCAP_ue="$(printf "\e[0m")" \
        LESS_TERMCAP_us="$(printf "\e[1;32m")" \
        man "$@"
}
