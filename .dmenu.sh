#!/bin/bash

source "./.color.sh"
source "./.font.sh"
source "./.screen.sh"

WIDTH=$(( $SCREEN_WIDTH - 406 ))
dmenu_run -q -nb "$BACKGROUND_COLOR" -nf "$FOREGROUND_COLOR" -sb "$ACCENT_COLOR" -fn "$FONT" -x 24 -h 24 -w $WIDTH
