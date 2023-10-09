#!/bin/bash
if wmctrl -l | grep -q "Alacritty";then
	wmctrl -a Alacritty
else
	alacritty -e tmux &
	wmctrl -a alacritty
fi
