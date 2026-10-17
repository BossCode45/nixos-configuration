{ inputs, ... }:
{
	flake.modules.nixos.teh-nix =
		{ config, lib, ... }:
		{
			options.teh-nix.nix = with lib; {
				enable = mkEnableOption "Use the TehNix nix settings";
			};

			config = lib.mkIf config.teh-nix.nix.enable {
				nix.nixPath = [ "/etc/nix/path" ];
				nix.registry.nixpkgs.flake = inputs.nixpkgs;
				environment.etc."nix/path/nixpkgs".source = inputs.nixpkgs;

				nix = {
					settings = {
						experimental-features = [
							"nix-command"
							"flakes"
						];
						auto-optimise-store = true;

						trusted-users = [ "boss" ];

						substituters = [
							"https://cache.nixos.org"
						];

						# trusted-public-keys = [
						#     "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
						# ];
					};
					optimise.automatic = true;
				};

				# nh's cleaner replaces nix.gc (the nh module asserts they aren't both on)
				programs.nh = {
					enable = true;
					clean = {
						enable = true;
						dates = "weekly";
						# --no-direnv keeps nix-direnv's gcroots so dev shells survive
						extraArgs = "--keep-since 7d --keep 5 --no-direnv";
					};
				};
			};
		};
}
