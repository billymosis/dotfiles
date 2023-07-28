#!/usr/bin/bash

# a hashmap to store all display details
declare -A DISPLAY_DET=(["HDMI-2"]="1920x1080" ["eDP-1"]="1366x768")

pid=$(xdotool search --classname ${1})

# if no floating window exists then exit
if [[ -z "$pid" ]]; then
	exit
# check if scratchpad is already visible
elif [[ -z $(bspc query -N -n .hidden) ]]; then
	bspc node $pid --flag hidden -f
	exit
# show scratchpad
else
	# getting focused window name
	DISPLAY_CURRENT=$(bspc query -M -m .focused --names)

	# if scratchpad needs to be shown on 2nd monitor
	# shift it by 1st monitor's width
	# otherwise no need to shift
	SHIFT_VAL=""
	BSPWM_FLOAT_WIDTH=""
	BSPWM_FLOAT_HEIGHT=""

	if [[ $DISPLAY_CURRENT == "HDMI-2" ]]; then
		SHIFT_VAL="1366"
		BSPWM_FLOAT_WIDTH=1860
		BSPWM_FLOAT_HEIGHT=1000
	elif [[ $DISPLAY_CURRENT == "eDP-1" ]]; then
		SHIFT_VAL="0"
		BSPWM_FLOAT_WIDTH=1300
		BSPWM_FLOAT_HEIGHT=700
	else
		echo "INCORRECT MONITOR SETTING!"
		exit 1
	fi

	# getting current monitor's resolution
	DISPLAY_CURRENT_RES=${DISPLAY_DET[$DISPLAY_CURRENT]}

	# splitting into width and height
	DISPLAY_RES_W="$(echo $DISPLAY_CURRENT_RES | cut -d'x' -f1)"
	DISPLAY_RES_H="$(echo $DISPLAY_CURRENT_RES | cut -d'x' -f2)"

	# small calculation to set to center of screen
	POS_X=$(echo "($DISPLAY_RES_W-$BSPWM_FLOAT_WIDTH)/2" | bc)
	POS_Y=$(echo "($DISPLAY_RES_H-$BSPWM_FLOAT_HEIGHT)/2" | bc)

	# move scratchpad to current window
	# unhide and focus on it
	bspc node $pid -d focused
	bspc node $pid --flag hidden -f
	bspc node $pid -f
	bspc node $pid -t floating

	# moving window to center of current window
	xdotool getactivewindow windowmove -- $POS_X $POS_Y
	# xdotool getactivewindow windowmove 0 0
	xdotool getactivewindow windowsize $BSPWM_FLOAT_WIDTH $BSPWM_FLOAT_HEIGHT
fi
