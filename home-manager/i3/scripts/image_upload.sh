#!/usr/bin/env bash
image_name=$(rofi -dmenu -l 0 -p "Image name")
xclip -selection clipboard -t image/png -o > ~/Documents/tehbox-files/$image_name
eval $(ssh-agent)
rsync ~/Documents/tehbox-files/$image_name files@tehbox.org:/srv/files
notify-send "uploaded https://files.tehbox.org/$image_name"
echo -n "https://files.tehbox.org/$image_name" | xclip -i -selection clipboard
