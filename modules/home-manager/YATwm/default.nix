{ inputs, config, ... }:
let
	hm = config.flake.modules.homeManager;
in
{
	flake.modules.homeManager.YATwm =
		{
			pkgs,
			lib,
			...
		}:
		{
			imports = [
				hm.polybar
				hm.rofi
				hm.kitty
				inputs.YATwm.homeManagerModules.default
			];
			home.packages = with pkgs; [
				i3lock
				xss-lock
				networkmanagerapplet
				flameshot
				picom
				nitrogen
				pamixer
				kitty
				alacritty
			];

			xsession.windowManager.YATwm = {
				enable = true;
				package = inputs.YATwm.packages.x86_64-linux.YATwm;
				useEmacsBinds = true;
				quitKey = "C-s-g";
				swapMods = false;
				keybinds =
					let
						left = "h";
						right = "l";
						up = "k";
						down = "j";
						wsBind = key: ws: {
							"s-${key}" = "changeWS ${ws}";
							"s-S-${key}" = "wToWS ${ws}";
						};
						wsBinds = workspaces: lib.attrsets.concatMapAttrs (key: ws: wsBind key ws) workspaces;
					in
					{
						# Important
						"s-E" = "exit";
						"s-R" = "reload";

						# Directions
						"s-${left}" = "focChange left";
						"s-${right}" = "focChange right";
						"s-${up}" = "focChange up";
						"s-${down}" = "focChange down";

						# Tiling
						"s-t" = "toggle";
						"s-f" = "fullscreen";

						# Application shortcuts
						"s-d" = "bashSpawn rofi -i -show drun -disable-history";
						"s-D" = "bashSpawn prime-run rofi -i -show drun -disable-history";
						"s-g" = "bashSpawn ~/bin/rofi-passmenu";
						"s-RET" = "bashSpawn kitty";
						# "s-r k" = "spawn kitty";
						"s-c" = "spawn firefox";
						"s-S--" = "bashSpawn emacsclient -c";
						"s-S" = "spawn flameshot gui";
						"s-x" = "spawn loginctl lock-session";
						"s-X" = "bashSpawn loginctl lock-session && systemctl suspend";
						"s-Q" = "kill";

						# Sound
						"s-[" = "spawn playerctl -p firefox play-pause";
						"s-]" = "spawn playerctl -p spotify play-pause";

						# Special workspaces
						"s-p s" = "changeWS 11";
						"s-S-p s" = "wToWS 11";
					}
					// wsBinds {
						"1" = "1";
						"2" = "2";
						"3" = "3";
						"4" = "4";
						"5" = "5";
						"6" = "6";
						"7" = "7";
						"8" = "8";
						"9" = "9";
						"0" = "10";
					};
				workspaces = [
					{ name = "1: A"; }
					{ name = "2: B"; }
					{ name = "3: C"; }
					{ name = "4: D"; }
					{ name = "5: E"; }
					{
						name = "6: F";
						monitorPriorities = [
							2
							1
						];
					}
					{
						name = "7: G";
						monitorPriorities = [
							2
							1
						];
					}
					{
						name = "8: H";
						monitorPriorities = [
							2
							1
						];
					}
					{
						name = "9: I";
						monitorPriorities = [
							2
							1
						];
					}
					{
						name = "10: J";
						monitorPriorities = [
							2
							1
						];
					}
					{
						name = "S";
						monitorPriorities = [ 1 ];
					}
				];
				startup = [
					{
						command = "~/.config/polybar/launch.sh";
						once = false;
					}
					{
						command = "picom --legacy-backends -fD 3";
						once = false;
					}
					{
						command = "xss-lock --transfer-sleep-lock -- i3lock -eti ~/Documents/lockscreen.png --nofork";
						bash = false;
					}
					{ command = "nitrogen --restore"; }
					{
						command = "nm-applet";
						once = false;
						bash = false;
					}
				];
				#extraConfig = "bindmode normal\n" + (builtins.readFile ./config);
			};
		};
}
