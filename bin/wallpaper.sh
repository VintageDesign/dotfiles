#!/bin/bash
# http://bit.ly/2ines3u

# Wallpaper's directory.
/usr/local/bin/himawaripy |& tee -a  /var/log/himawaripy.log
dir="${HOME}/.cache/himawaripy/"

# export DBUS_SESSION_BUS_ADDRESS environment variable
PID=$(pgrep gnome-session)
export DBUS_SESSION_BUS_ADDRESS=$(grep -z DBUS_SESSION_BUS_ADDRESS "/proc/$PID/environ" | cut -d= -f2-)

echo "Grabbing saved image"
wallpaper=$(find "${dir}" -type f)

# Change wallpaper.
# http://bit.ly/HYEU9H
echo "Setting wallpaper"
gsettings set org.gnome.desktop.background picture-options "scaled"
echo "Setting wallpaper URI"
gsettings set org.gnome.desktop.background picture-uri "file://${wallpaper}"
