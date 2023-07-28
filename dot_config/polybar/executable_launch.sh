#! /bin/sh 

# Terminate already running bar instances
# If all your bars have ipc enabled, you can use 
polybar-msg cmd quit
# Otherwise you can use the nuclear option:
# killall -q polybar

polybar -c "$HOME/.config/polybar/config.ini" example

echo "Bars launched..."
