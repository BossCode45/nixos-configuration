{
    description = "My nixos configuration";

    inputs = {
        nixpkgs.url = "github:nixos/nixpkgs/nixos-24.11";
        home-manager = {
            url = "github:nix-community/home-manager/release-24.11";
            inputs.nixpkgs.follows = "nixpkgs";
        };
        stylix = {
            url = "github:danth/stylix/release-24.11";
            inputs.nixpkgs.follows = "nixpkgs";
        };
        spicetify-nix = {
            url = "github:Gerg-L/spicetify-nix";
            inputs.nixpkgs.follows = "nixpkgs";
        };
        YATwm = {
            #url = "git+https://git.tehbox.org/cgit/boss/YATwm.git";
            url = "github:BossCode45/YATwm";
            #url = "git+file:///home/boss/Documents/Coding/WM/YATwm";
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
            url = "github:MarceColl/zen-browser-flake";
            inputs.nixpkgs.follows = "nixpkgs";
        };
    };

    outputs = inputs@{ nixpkgs, ... }: {
        nixosConfigurations = {
            nixy = nixpkgs.lib.nixosSystem {
                system = "x86_64-linux";
                specialArgs = {inherit inputs;};
                modules = [
                    ./configuration.nix

                    inputs.home-manager.nixosModules.home-manager
                    {
                        home-manager.useGlobalPkgs = true;
                        home-manager.useUserPackages = true;

                        home-manager.users.boss = import ./home-manager/home.nix;
                        home-manager.extraSpecialArgs = {inherit inputs;};
                    }

                    inputs.stylix.nixosModules.stylix
                ];
            };
        };
    };
}
