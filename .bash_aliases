alias say='spd-say'
alias alert='notify-send --urgency=low -i "$([ $? = 0 ] && echo terminal || echo error)" "$(history|tail -n1|sed -e '\''s/^\s*[0-9]\+\s*//;s/[;&|]\s*alert$//'\'')"'

alias grep='grep --color'                     # show differences in colour
alias egrep='egrep --color=auto'              # show differences in colour
alias fgrep='fgrep --color=auto'

alias ls='ls -hF --color=tty'                 # classify files in colour
alias ll='ls -alF'
alias la='ls -A'
alias l='ls -CF'
alias fort='fortune -a | cowsay'

alias ccat='pygmentize -g'

alias upd='sudo apt update'
alias upg='sudo apt upgrade'
alias acl='sudo apt-get autoclean'
alias arem='sudo apt-get autoremove'

alias git-yolo='git commit -am "`curl -s http://whatthecommit.com/index.txt `"'

alias xo='xdg-open'
alias ghci='stack ghci'
alias ghc='stack ghc'

if [ -x /usr/bin/dircolors ]; then
    test -r ~/.dircolors && eval "$(dircolors -b ~/.dircolors)" || eval "$(dircolors -b)"
    alias ls='ls --color=auto'
    #alias dir='dir --color=auto'
    #alias vdir='vdir --color=auto'

    alias grep='grep --color=auto'
    alias fgrep='fgrep --color=auto'
    alias egrep='egrep --color=auto'
fi

rhyme(){
    { cat /usr/share/dict/words; printf %s\\n "$1"; } | rev | sort | rev | grep -FxC15 -e "${1?}" | grep -Fxve "$1" | shuf -n1;
}

wut(){
    cows=(apt cock elephant hellokitty meow ren suse vader beavis.zen cower elephant-in-snake kiss milk sheep three-eyes vader-koala bong daemon eyes kitty moofasa skeleton turkey www bud-frogs default flaming-sheep koala moose snowman turtle bunny dragon-and-cow ghostbusters kosh mutilated sodomized-sheep tux calvin dragon gnu luke-koala pony stegosaurus unipony cheese duck head-in mech-and-cow pony-smaller stimpy unipony-smaller );
    options=(b d g p s t w y);
    random_cow=RANDOM%52
    random_option=RANDOM%7

    fortune | cowsay -n -f ${cows[random_cow]} -${options[random_option]}
}

cow(){
    options=(b d g p s t w y);
    random_option=RANDOM%8

    fortune -a | cowsay -n -${options[random_option]}
}
