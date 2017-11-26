#!/bin/bash

# Sends a wake on LAN packet to the ip address (not hostname) given.

wake()
{
    echo "Waking $1"
    wakeonlan "$(arp -n | grep "$1" | grep -io '[0-9A-F]\{2\}\(:[0-9A-F]\{2\}\)\{5\}')"
}

wake "$1"

