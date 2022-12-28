#!/bin/sh

TOGGLE=$HOME/.toggle

if [ ! -e $TOGGLE ]; then
  touch $TOGGLE
  autorandr -c laptop
else
  rm $TOGGLE
  autorandr -c docked
fi
