#!/bin/bash

# Check if a Tmux session named "Unity" exists
if tmux has-session -t $1 2>/dev/null; then
    # If the session exists, attach to it
    tmux send-keys -t $1 "nvim $2" C-m
else
    # If the session doesn't exist, create a new one
    tmux new-session -d -s $1
    # Open Neovim in the new Tmux session with the specified file
    tmux send-keys -t $1 "nvim $2" C-m
fi
