{ inputs, config, ... }:
let
    system = "x86_64-linux";
    pkgs = import inputs.nixpkgs { inherit system; };
    deployPkgs = import inputs.nixpkgs {
        inherit system;
        overlays = [
            inputs.deploy-rs.overlays.default # or deploy-rs.overlays.default
            (self: super: { deploy-rs = { inherit (pkgs) deploy-rs; lib = super.deploy-rs.lib; }; })
        ];
    };
    deployCfg = config.flake.deploy;
in
{
    flake.deploy.nodes.nixnode = {
        hostname = "tehbox.org";
        profiles.system = {
            user = "root";
            sshUser = "boss";
            interactiveSudo = true;
            path = deployPkgs.deploy-rs.lib.activate.nixos config.flake.nixosConfigurations.nixnode;
        };
    };

    perSystem =
        { system, ... }:
        {
            checks = inputs.deploy-rs.lib.${system}.deployChecks deployCfg;
        };
}
