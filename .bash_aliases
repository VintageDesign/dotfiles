#!/bin/bash

alias alert='notify-send --urgency=low -i "$([ $? = 0 ] && echo terminal || echo error)" "$(history|tail -n1|sed -e '\''s/^\s*[0-9]\+\s*//;s/[;&|]\s*alert$//'\'')"'

alias grep='grep --color=auto'
alias egrep='egrep --color=auto'
alias fgrep='fgrep --color=auto'

alias matlab='/usr/local/MATLAB/R2017a/bin/matlab'

alias ls='ls -h --color=auto'
alias ll='ls -alF'
alias la='ls -A'
alias l='ls -CF'

alias back="cd -"
alias xo='1>/dev/null 2>/dev/null xdg-open'

alias upd='sudo apt update'
alias upg='sudo apt upgrade'
alias acl='sudo apt-get autoclean'
alias arem='sudo apt-get autoremove'

alias git-yolo='git commit -am "$(curl -s http://whatthecommit.com/index.txt)"'

