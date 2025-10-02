#!/bin/bash

commands=$(cat <<EOF
Reload tmux config  : tmux source-file ~/.tmux.conf
Open nvim config    : nvim ~/.config/nvim/init.lua
Show disk usage     : df -h | less
Show processes      : htop
Show IP address     : ip addr show | less
Show used port      : ss -tulpn | less
FE-BRAVO            : smug start trading-ui
FE-CHARLIE          : smug start c-trading-ui
GW-CHARLIE          : smug start c-rest-gw
GW-Bravo            : smug start rest-gw
Rename Window       : tmux command-prompt -p "New window name:" -I "#W" "rename-window '%%'; display-message 'Window renamed to %%'"
Rename Session      : tmux command-prompt -p "New session name:" -I "#S" "rename-session '%%'; display-message 'Session renamed to %%'"
lazy-git            : lazygit
lazy-docker         : lazydocker
EOF
)

selected_line=$(echo "$commands" | fzf --exit-0)
selected_command=$(echo "$selected_line" | awk -F ' : ' '{print $2}')


if [[ -n $selected_command ]]; then
    "$SHELL" -c "$selected_command"
else
    tmux display-message "No command selected."
    exit 0
fi
