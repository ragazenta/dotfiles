#!/bin/bash

source "./.color.sh"
source "./.font.sh"
source "./.screen.sh"

PIDFILE="/tmp/network-dzen.pid"

if [ -e $PIDFILE ]; then
    kill -9 $(<"$PIDFILE")
    rm $PIDFILE
    exit
fi

WIDTH=162
X=$(( $SCREEN_WIDTH / 2 + 3 ))
Y=30

conky -c ".network.conf" | dzen2 -p -fn "$FONT" -ta l -l 6 -x $X -y $Y -w $WIDTH -bg "$BACKGROUND_COLOR" -e "onstart=uncollapse;onexit=exec:rm -f /tmp/network-dzen.pid;button1=exit" & echo $! > $PIDFILE
