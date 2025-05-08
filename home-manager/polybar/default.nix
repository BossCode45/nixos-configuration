{
    config,
    pkgs,
    ...
} : {
    home.file.".config/polybar/launch.sh" = {
        source = ./launch.sh;
        executable = true;
    };
    home.file.".config/polybar/config.ini" = {
        source = ./config.ini;
#        onChange = ''
#${pkgs.procps}/bin/pkill polybar
#PATH=$PATH:${pkgs.polybarFull}/bin:${pkgs.lxrandr}/bin ~/.config/polybar/launch.sh
#'';
    };
    home.packages = with pkgs; [
		polybarFull
    ];
}
