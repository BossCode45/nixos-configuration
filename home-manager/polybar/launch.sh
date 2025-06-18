#!/usr/bin/env bash

# Terminate already running bar instances
# If all your bars have ipc enabled, you can use 
polybar-msg cmd quit
# Otherwise you can use the nuclear option:
# killall -q polybar

# Launch bar1 and bar2
echo "---" | tee -a /tmp/polybarstatus.log

for m in $(xrandr --query | grep " connected" | cut -d" " -f1); do
    if [ $(xrandr | grep $m | grep primary | wc -l) -eq 1 ]; then
        MONITOR=$m polybar mainbar | tee -a /tmp/mainpolybar.log & disown
    else
        MONITOR=$m polybar extrabar | tee -a /tmp/extrapolybar.log & disown
    fi
done

echo "Bars launched..."
