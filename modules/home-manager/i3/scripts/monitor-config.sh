#!/bin/sh

choice=$(echo -e "One monitor\nTwo monitors" | rofi -dmenu -i -p "What monitor setup to use")

monitor1=$(xrandr | grep -E "eDP(-1(-1)?)?" | awk '{print $1 }')
monitor2=$(xrandr | grep -E "HDMI(-A-0)?(-1(-1)?)?" | awk '{print $1 }')

case $choice in
	"One monitor")
		xrandr --output $monitor1 --primary --mode 1920x1080 --rate 144 --pos 0x0 --rotate normal --output $monitor2 --off
		sleep 1
		i3-msg restart
		;;
	"Two monitors")
		xrandr --output $monitor1 --primary --mode 1920x1080 --rate 144 --pos 0x0 --rotate normal --output $monitor2 --mode 1920x1080 --rate 144 --pos 1920x0 --rotate normal
		sleep 1
		i3-msg restart
		;;
	*)
		notify-send "Invalid response, canceling"
		;;
esac

