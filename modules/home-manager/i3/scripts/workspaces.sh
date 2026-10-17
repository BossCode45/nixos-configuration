choice=$(cat ~/.i3_commands/workspaces.txt | rofi -dmenu -i -p "Which workspace to switch to")
if [[ $1 == "move" ]]
then
	i3-msg move container to workspace \"$choice\"
else
	i3-msg workspace \"$choice\"
fi
