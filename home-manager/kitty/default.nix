{
    pkgs,
    config,
    ...
}:
{
    programs.kitty = {
        enable = true;
        keybindings = {
            "control+shift+c" = "copy_to_clipboard";
            "control+shift+v" = "paste_from_clipboard";
        };
        settings = {
            #font_family = "Cousine Nerd Font";
            #font_size = "10.0";
            #background_opacity = "0.8";
            term = "xterm-256color";
            enable_audio_bell = "no";
            mouse_hide_wait = 2;
            window_padding_width = 4;
        };
        #extraConfig = (builtins.readFile ./palenight.conf);
    };
}
