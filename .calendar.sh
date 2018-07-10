#!/bin/bash

source "./.color.sh"
source "./.font.sh"
source "./.screen.sh"

PIDFILE="/tmp/calendar-dzen.pid"

if [ -e $PIDFILE ]; then
    kill -9 $(<"$PIDFILE")
    rm $PIDFILE
    exit
fi

TODAY=`date +"%d" | sed "s/^0//"`
MONTH=`date +"%m"`
YEAR=`date +"%Y"`

WIDTH=190
X=$(( $SCREEN_WIDTH - $WIDTH - 4 ))
Y=30
LEFTSPACE=18
LINEPADDING=25
LINESIZE="140x1"

(echo `date +"^p($LEFTSPACE) ^fg($ACCENT_COLOR)%A^fg() %d/%m/%Y %n"`; echo; echo `date +"^p($LEFTSPACE) ^fg($ACCENT_COLOR)%B %Y"`; cal | sed "2,8!d" | sed "/./!d" | sed "s/^/^p($LEFTSPACE) /" | sed "s/$/ /" | sed "s/Su Mo Tu We Th Fr Sa/^fg($ACCENT_COLOR)Su Mo Tu We Th Fr Sa/" | sed -e "s/ $TODAY /^fg($ACCENT_COLOR) $TODAY ^fg()/"; echo "^p($LINEPADDING)^fg($ACCENT_COLOR)^r($LINESIZE)" 

for i in {1..12}; do
    NEXTMONTH=`expr $MONTH + $i`
    [ $NEXTMONTH -eq 13 ] && YEAR=`expr $YEAR + 1`
    M=`expr $NEXTMONTH % 12`
    if [ $M -eq 0 ]; then
        M=12
    fi
    echo `date -d "$YEAR-$M-1" +"^p($LEFTSPACE) ^fg($ACCENT_COLOR)%B %Y"`;cal $M $YEAR | sed "2,8!d" | sed "/./!d" | sed "s/^/^p($LEFTSPACE) /" | sed "s/$/ /" | sed "s/Su Mo Tu We Th Fr Sa/^fg($ACCENT_COLOR)Su Mo Tu We Th Fr Sa/"; echo "^p($LINEPADDING)^fg($ACCENT_COLOR)^r($LINESIZE)"
done) \
| dzen2 -l 33 -p -ta l -fn "$MONOSPACE_FONT" -bg "$BACKGROUND_COLOR" -e "onstart=uncollapse,scrollhome;onexit=exec:rm -f /tmp/calendar-dzen.pid;button1=exit;button3=exit;button4=scrollup;button5=scrolldown" -w $WIDTH -x $X -y $Y & echo $! > $PIDFILE
