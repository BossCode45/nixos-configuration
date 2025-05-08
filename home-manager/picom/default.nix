{
    pkgs,
    config,
    ...
}:
{
    services.picom = {
        enable = true;
        fade = true;
        fadeDelta = 3;
        fadeExclude = [
            "window_type *= 'tooltip'"
        ];
        settings = {
            corner-radius = 10;
        };
    };
}
