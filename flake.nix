{
	description = "My nixos configuration";

	inputs = {
		nixpkgs.url = "github:nixos/nixpkgs/nixos-26.05";
		flake-parts = {
			url = "github:hercules-ci/flake-parts";
			inputs.nixpkgs-lib.follows = "nixpkgs";
		};
		import-tree.url = "github:vic/import-tree";
		home-manager = {
			url = "github:nix-community/home-manager/release-26.05";
			inputs.nixpkgs.follows = "nixpkgs";
		};
		stylix = {
			url = "github:danth/stylix/release-26.05";
			inputs.nixpkgs.follows = "nixpkgs";
		};
		spicetify-nix = {
			url = "github:Gerg-L/spicetify-nix";
			inputs.nixpkgs.follows = "nixpkgs";
		};
		# YATwm = {
		#     #url = "git+https://git.tehbox.org/boss/YATwm.git";
		#     url = "github:BossCode45/YATwm";
		#     # url = "git+file:///home/boss/Documents/Coding/WM/YATwm";
		#     inputs.nixpkgs.follows = "nixpkgs";
		# };
		STK = {
			url = "git+file:///home/boss/stk";
			inputs.nixpkgs.follows = "nixpkgs";
		};
		# hyprland = {
		#     url = "github:hyprwm/Hyprland";
		#     inputs.nixpkgs.follows = "nixpkgs";
		# };
		hyprlock = {
			url = "github:hyprwm/hyprlock";
			inputs.nixpkgs.follows = "nixpkgs";
		};
		nil = {
			url = "github:oxalica/nil";
			inputs.nixpkgs.follows = "nixpkgs";
		};
		polymc = {
			url = "github:PolyMC/PolyMC";
			inputs.nixpkgs.follows = "nixpkgs";
		};
		zen-browser = {
			url = "github:0xc000022070/zen-browser-flake";
			inputs.nixpkgs.follows = "nixpkgs";
			inputs.home-manager.follows = "home-manager";
		};
		nixcord = {
			url = "github:kaylorben/nixcord";
			inputs.nixpkgs.follows = "nixpkgs";
		};
		sops = {
			url = "github:Mic92/sops-nix";
			inputs.nixpkgs.follows = "nixpkgs";
		};
		deploy-rs = {
			url = "github:serokell/deploy-rs";
			inputs.nixpkgs.follows = "nixpkgs";
		};
		nixos-mailserver = {
			url = "gitlab:simple-nixos-mailserver/nixos-mailserver/nixos-26.05";
			inputs.nixpkgs.follows = "nixpkgs";
		};
		claude-desktop = {
			url = "github:aaddrick/claude-desktop-debian";
			inputs.nixpkgs.follows = "nixpkgs";
		};
		neodrive-website = {
			url = "github:BossCode45/neodrive-website";
			inputs.nixpkgs.follows = "nixpkgs";
		};

		#     hytale-launcher = {
		#         url = "github:TNAZEP/HytaleLauncherFlake";
		#         inputs.nixpkgs.follows = "nixpkgs";
		#     };
	};

	outputs = inputs: inputs.flake-parts.lib.mkFlake { inherit inputs; } (inputs.import-tree ./modules);
}
