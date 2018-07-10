#!/bin/bash

source "./.color.sh"
source "./.font.sh"
source "./.screen.sh"

X=$(( $SCREEN_WIDTH - 962 ))
dzen2 -x $X -w 276 -ta l -h 24 -fn "$FONT" -bg "$BACKGROUND_COLOR" -e ""
