{ inputs, ... }:
{
    nix.nixPath = [ "/etc/nix/path" ];
    nix.registry.nixpkgs.flake = inputs.nixpkgs;
    environment.etc."nix/path/nixpkgs".source = inputs.nixpkgs;
    
    nix = {
        settings = {
            experimental-features = [ "nix-command" "flakes" ];
            auto-optimise-store = true;
            
            trusted-users = [ "boss" ];

            substituters = [
                "https://cache.nixos.org"
            ];

            # trusted-public-keys = [
            #     "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
            # ];
        };
        gc = {
            automatic = true;
            dates = "weekly";
            options = "--delete-older-than +7";
        };
        optimise.automatic = true;
    };
}
