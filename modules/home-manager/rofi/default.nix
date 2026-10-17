{ ... }:
{
	flake.modules.homeManager.rofi =
		{
			pkgs,
			config,
			...
		}:
		{
			home.file.".config/rofi" = {
				source = ./config;
				recursive = true;
			};
			home.packages = [
				pkgs.rofi
			];
		};
}
