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

# Give list of unique commands in history and count their usage.
uhist()
{
	 history | awk '{print $2}' | awk 'BEGIN {FS="|"} {print $1}' | sort | uniq -c | sort -r
}

# Lists your path one item per line
path()
{
	 echo $PATH | tr ':' '\n'
}

# grabs the local IP
localip()
{
    echo "local IP(s):"
    echo ""
    ifconfig | perl -nle'/dr:(\S+)/ && print $1'
    # echo "local IP: $(hostname -I)"
}

# grabs the external IP
publicip()
{
    echo "public IP:"
    echo ""
    curl -s 'ipecho.net/plain'
    echo ""
}

# get IP information
ipinfo()
{
    localip
    echo ""
    publicip
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
    git log --author="$*" --pretty=tformat: --numstat | cut -f 1 | sed '/^$/d' | paste -s -d+ | bc
}

# Gives number of removals author has made in current git repo
removals()
{
    git log --author="$*" --pretty=tformat: --numstat | cut -f 2 | sed '/^$/d' | paste -s -d+ | bc
}

# converts CRLF endings to LF endings
dos2unix()
{
	 sed -i 's/.$//' $1
}

# converts LF endings to CRLF endings
unix2dos()
{
	 # requires GNU sed
	 sed -i 's/$/\r/' $1
}

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
