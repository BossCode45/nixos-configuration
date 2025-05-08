{
    config,
    pkgs,
    ...
} : {
    home.file.".config/waybar/" = {
        source = ./config;
        onChange = "${pkgs.procps}/bin/pkill waybar && ${pkgs.hyprland}/bin/hyprctl dispatch exec waybar || ${pkgs.hyprland}/bin/hyprctl dispatch exec waybar";
        recursive = true;
    };
    home.packages = with pkgs; [
		waybar
        pamixer
        wtype
    ];
}
