#!/bin/bash

if wmctrl -l | grep -q "nvim";then
	wmctrl -a nvim
	nvr $@
else
	wezterm start -- nvr $@
fi
