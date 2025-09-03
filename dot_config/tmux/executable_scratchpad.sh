#!/bin/bash

# Define the scratchpad session name
SCRATCHPAD_NAME="scratchpad"

# If the scratchpad session exists, toggle its visibility
if tmux has-session -t "$SCRATCHPAD_NAME" 2>/dev/null; then
    # Check if the scratchpad session is attached to any client
    # This is a bit of a trick to see if it's currently visible
    if tmux list-clients -F "#{session_name}" | grep -q "^$SCRATCHPAD_NAME$"; then
        # If it's visible, detach it to hide it
        tmux detach -s "$SCRATCHPAD_NAME"
    else
        # If it's not visible, display it as a popup
        tmux display-popup -E "tmux attach-session -t '$SCRATCHPAD_NAME'"
    fi
else
    # If the scratchpad session doesn't exist, create it as a popup
    tmux display-popup -E "tmux new-session -s '$SCRATCHPAD_NAME' 'zsh'"
fi
