#!/usr/bin/env bash
choice=$(echo -e "Sleep\nLock\nLock and sleep\nExit i3" | rofi -dmenu -i -p "What do you want to do")
case $choice in
	"Sleep")
		systemctl suspend
	;;
	"Lock")
		i3lock -eti /usr/share/backgrounds/lockscreen.png 
	;;
	"Lock and sleep")
		i3lock -eti /usr/share/backgrounds/lockscreen.png 
		systemctl suspend
	;;
	"Exit i3")
		i3-msg exit
	;;
	*)
		notify-send "Canceling"
	;;
esac
