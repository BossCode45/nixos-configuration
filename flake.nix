{
    description = "My nixos configuration";

    inputs = {
        nixpkgs.url = "github:nixos/nixpkgs/nixos-26.05";
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

    outputs = inputs@{self, nixpkgs, ... }: let
        system = "x86_64-linux";
        pkgs = import nixpkgs { inherit system; };
        deployPkgs = import nixpkgs {
            inherit system;
            overlays = [
                inputs.deploy-rs.overlays.default # or deploy-rs.overlays.default
                (self: super: { deploy-rs = { inherit (pkgs) deploy-rs; lib = super.deploy-rs.lib; }; })
            ];
        };
    in
      {
          nixosConfigurations = {
              nixy = nixpkgs.lib.nixosSystem {
                  system = "x86_64-linux";
                  specialArgs = {inherit inputs;};
                  modules = [
                      ./my-pkgs
                      ./modules
                      
                      ./hardware-setups/tuf.nix
                      ./computers/nixy.nix

                      {
                          environment.systemPackages = [
                              deployPkgs.deploy-rs.deploy-rs
                          ];
                      }
                      
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
              nixnode = nixpkgs.lib.nixosSystem {
                  system = "x86_64-linux";
                  specialArgs = {inherit inputs;};
                  modules = [
                      ./modules
                      ./hardware-setups/linode.nix
                      ./computers/nixnode.nix
                  ];
              };
          };

          deploy.nodes.nixnode = {
              hostname = "tehbox.org";
              profiles.system = {
                  user = "root";
                  sshUser = "boss";
                  interactiveSudo = true;
                  path = deployPkgs.deploy-rs.lib.activate.nixos self.nixosConfigurations.nixnode;
              };
          };

          checks = builtins.mapAttrs (system: deployLib: deployLib.deployChecks self.deploy) inputs.deploy-rs.lib;
          
          packages.x86_64-linux.teh-website = (nixpkgs.legacyPackages.x86_64-linux.callPackage ./website { });
          packages.x86_64-linux.stk-installers = (nixpkgs.legacyPackages.x86_64-linux.callPackage ./my-pkgs/stk-installers.nix { });
      };

}
