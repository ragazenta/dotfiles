#!/bin/bash

source "./.color.sh"
source "./.font.sh"

PIDFILE="/tmp/shutdown-dzen.pid"

if [ -e $PIDFILE ]; then
    kill -9 $(<"$PIDFILE")
    rm $PIDFILE
    exit
fi

X=583
Y=88
WIDTH=220
HEIGHT=44

(echo "^ca(1, sudo poweroff)^bg($ACCENT_COLOR)  SHUTDOWN  ^bg()^ca() ^ca(1, sudo reboot)^bg($FOREGROUND_COLOR)^fg($SECONDARY_BACKGROUND_COLOR)    REBOOT    ^fg()^bg()^ca() ^bg($SECONDARY_BACKGROUND_COLOR)    CANCEL    ^bg()") \
| dzen2 -p -fn "$FONT" -ta c -x $X -y $Y -w $WIDTH -h $HEIGHT -bg "$BACKGROUND_COLOR" -e "onstart=uncollapse;onexit=exec:rm -f /tmp/shutdown-dzen.pid;button1=exit" & echo $! > $PIDFILE
