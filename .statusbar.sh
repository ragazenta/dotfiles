#!/bin/bash

source "./.color.sh"
source "./.font.sh"
source "./.screen.sh"

CONFIG=~/.statusbar.conf

if [ $SCREEN_WIDTH -eq 1024 ]; then
    CONFIG=~/.statusbar.1024.conf
fi

conky -c $CONFIG | dzen2 -dock -ta l -h 24 -fn "$FONT" -bg "$BACKGROUND_COLOR" -e ""
