#!/bin/bash
# The base16 dark palette from Tilix
# gsettings set org.gnome.Terminal.Legacy.Profile:/org/gnome/terminal/legacy/profiles:/:b1dcc9dd-5262-4d8d-a863-c897e6d979b9/ palette '["#1E1E1E", "#CF6A4C", "#8F9D6A", "#F9EE98", "#7587A6", "#9B859D", "#AFC4DB", "#A7A7A7", "#5F5A60", "#CF6A4C", "#8F9D6A", "#F9EE98", "#7587A6", "#9B859D", "#AFC4DB", "#FFFFFF"]'

SETTINGS="$DOTFILES_SETUP_SCRIPT_DIR/dconf/gnome-terminal.dconf"
if prompt_default_no "Update Gnome Terminal settings?"; then
    if [[ ! -f "$SETTINGS.bak" ]]; then
        dconf dump /org/gnome/terminal/legacy/profiles:/ >"$SETTINGS.bak"
    fi
    dconf load /org/gnome/terminal/legacy/profiles:/ <"$SETTINGS"
elif prompt_default_no "Save current Gnome Terminal settings?"; then
    dconf dump /org/gnome/terminal/legacy/profiles:/ >"$SETTINGS"
fi
