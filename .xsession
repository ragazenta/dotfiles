#!/bin/sh

SESSION="xmonad"

xrdb ~/.Xresources
urxvtd -q -o -f

if [ $SESSION = "xmonad" ]; then
    xsetroot -cursor_name left_ptr
    feh --no-xinerama --bg-fill '/home/renjaya/Pictures/Ryan Schroeder.jpg' 
    xfce4-power-manager &
    xfce4-volumed-pulse &
    nm-applet &
    compton -cCGfz --shadow-exclude "i:e:xfce4-notifyd" --shadow-exclude "i:e:dzen2" --shadow-exclude "n:e:dzen slave" --shadow-exclude "i:e:dmenu" --shadow-exclude "class_g = 'Firefox' && argb" -b
    /usr/libexec/polkit-gnome-authentication-agent-1 &
    xmonad
fi
