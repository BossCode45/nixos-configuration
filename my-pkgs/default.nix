{ config, pkgs, lib, ... }:
{
    nixpkgs.overlays = [
        (final: prev: {
            adom = prev.callPackage ./adom.nix { };
        })
    ];
}
