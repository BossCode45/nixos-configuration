{ inputs, ... }:
{
    flake.modules.nixos.my-pkgs =
        { config, pkgs, lib, ... }:
        {
            nixpkgs.overlays = [
                (final: prev: {
                    adom = inputs.self.packages.${final.stdenv.hostPlatform.system}.adom;
                })
            ];
        };
}
