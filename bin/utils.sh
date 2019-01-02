#!/bin/bash
##################
# Useful functions - to be sourced in .bashrc
##################

# go up n levels
up()
{
    TMP=$PWD
    LEVELS=${1:-1}
    for _ in $(seq "$LEVELS"); do
        cd ..
    done
    # $OLDPWD allows for `cd -`
    export OLDPWD=$TMP
}

# View a random man page
randman()
{
    man "$(ls -1 /usr/share/man/man?/ | shuf -n1 | cut -d. -f1)"
}

# a convenience wrapper around window.py
window()
{
    python3 ~/bin/window.py "$@"
}

# attempt to rhyme the given word
rhyme()
{
    { cat /usr/share/dict/words; printf %s\\n "$1"; } | rev | sort | rev | grep -FxC15 -e "${1?}" | grep -Fxve "$1" | shuf -n1;
}

# grabs the local IP
localip()
{
    echo "local IP(s):"
    echo ""
    # ifconfig | perl -nle'/dr:(\S+)/ && print $1'
    echo "local IP: $(hostname -I)"
}

# grabs the external IP
publicip()
{
    echo "public IP:"
    echo ""
    curl -s 'ipecho.net/plain'
    echo ""
}

# sorts directories by size
dsort()
{
    du -a -d 1 -h | sort -h
}

# completely remove a package - probably shouldn't use
completely_remove_package()
{
    apt-get purge "$("apt-cache depends $1 | awk '{ print $2 }' | tr '\n' ' '")"
}

# Gives number of additions author has made in current git repo
additions()
{
    git log --author="$*" --pretty=tformat: --numstat |                        \
        awk '{ add += $1; subs += $2; loc += $1 - $2 } END                    \
             { printf "added lines: %s removed lines: %s total lines: %s\n", add, subs, loc }' -
}

# converts CRLF endings to LF endings
dos2unix()
{
    sed -i 's/.$//' "$1"
}

# converts LF endings to CRLF endings
unix2dos()
{
    # requires GNU sed
    sed -i 's/$/\r/' "$1"
}

# Browse git log
gl() {
    git log --graph --color=always \
        --format="%C(auto)%h%d %s %C(black)%C(bold)%an, %cr" "$@" |
    fzf --ansi --no-sort --reverse --preview  "echo {} | grep -o '[a-f0-9]\{7\}' | head -1 | xargs -I % sh -c 'git show --color=always %'" \
        --bind "enter:execute:
                (grep -o '[a-f0-9]\{7\}' | head -1 |
                xargs -I % sh -c 'git show --color=always % | less -R') << 'FZF-EOF'
                {}
FZF-EOF"
}
