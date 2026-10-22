{ inputs, config, ... }:
let
	hm = config.flake.modules.homeManager;
in
{
	flake.modules.homeManager.i3 =
		{
			config,
			pkgs,
			...
		}:
		{
			imports = [
				hm.polybar
				hm.rofi
				hm.kitty
				hm.picom
			];
			xsession.enable = true;
			xsession.windowManager.i3 = {
				enable = true;
				package = pkgs.i3;
			};
			xdg.configFile."i3/config".enable = false;
			home.file.".config/i3/config" = {
				source = ./config;
				onChange = "${pkgs.i3}/bin/i3-msg restart";
			};
			home.packages = with pkgs; [
				i3lock
				xss-lock
				networkmanagerapplet
				flameshot
				picom
				nitrogen
				pamixer
				inputs.self.packages.${pkgs.stdenv.hostPlatform.system}.i3-commands
				inputs.self.packages.${pkgs.stdenv.hostPlatform.system}.rofi-passmenu
			];
		};
}
