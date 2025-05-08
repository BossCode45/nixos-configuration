# let
#   nixpkgs = fetchTarball "https://github.com/NixOS/nixpkgs/tarball/nixos-24.11";
#   pkgs = import nixpkgs { config = {}; overlays = []; };
# in
# {
#   i3-commands = pkgs.callPackage ./i3-commands.nix { };
# }


{
    config,
    pkgs,
    ...
} : {
    imports = [
        ../polybar
        ../rofi
        ../kitty
        ../picom
    ];
    xsession.enable = true;
    xsession.windowManager.i3 = {
        enable = true;
        package = pkgs.i3-gaps;
    };
    xdg.configFile."i3/config".enable = false;
    home.file.".config/i3/config" = {
        source = ./config;
        onChange = "${pkgs.i3-gaps}/bin/i3-msg restart";
    };
    home.packages = with pkgs; [
		i3lock
        xss-lock
		networkmanagerapplet
		flameshot
		picom
		nitrogen
        pamixer
        (pkgs.callPackage ./i3-commands.nix { })
    ];
}
