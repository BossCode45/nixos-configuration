{
    pkgs,
    lib,
    inputs,
    ...
}:
{
    imports = [
        ../rofi
        ../kitty
        ../waybar
        ../hyprpaper
    ];

    home.file.".config/hypr/hyprlock.conf".source = ./hyprlock.conf;
    
    wayland.windowManager.hyprland= {
        enable = true;
        xwayland.enable = true;
	    systemd.variables = ["--all"];
        #package = inputs.hyprland.packages.${pkgs.system}.hyprland;
        #portalPackage = inputs.hyprland.packages.${pkgs.system}.xdg-desktop-portal-hyprland;
        settings = {
            "$mod" = "SUPER";
            exec-once = [
                "waybar"
                "xss-lock --transfer-sleep-lock -- hyprlock"
                "nm-applet"
                "hyprpaper"
            ];
            bind =
                [
                    "$mod, C, exec, firefox"
                    ", Print, exec, grimblast copy area"
                    "$mod, D, exec, rofi -i -show drun -disable-history"
                    "$mod Shift, E, exit"
                    "$mod, Return, exec, kitty"
                    "$mod, T, togglesplit"
                    "$mod Control, left, workspace, m-1"
                    "$mod Control, h, workspace, m-1"
                    "$mod Control, right, workspace, m+1"
                    "$mod Control, l, workspace, m+1"
                    "$mod, x, exec, hyprlock"
                    "$mod Shift, x, exec, hyprlock"
                    "$mod Shift, x, exec, systemctl suspend"
                    "$mod Shift, MINUS, exec, emacsclient -c"
                    "ALT, Tab, focusmonitor, +1"
                    "$mod, G, exec, bash /home/boss/bin/rofi-passmenu"
                    ", XF86AudioRaiseVolume, exec, pamixer -i 5"
                    ", XF86AudioLowerVolume, exec, pamixer -d 5"
                    "$mod Shift, Q, killactive"
                    "$mod, F, fullscreen"
                    "$mod Shift, space, togglefloating"
                    "$mod, mouse:272, movewindow"
                    ", XF86AudioPlay, exec, playerctl play-pause"
                    "$mod, bracketleft, exec, playerctl -p firefox play-pause"
                    "$mod, bracketright, exec, playerctl -p spotify play-pause"
                    "$mod Shift, S, exec spectacle -r"
                ]
                ++ (
                    # workspaces
                    # binds $mod + [shift +] {1..10} to [move to] workspace {1..10}
                    builtins.concatLists (builtins.genList (
                        x: let
                            key = let
                                c = (x + 1) / 10;
                            in toString (x + 1 - (c * 10));
                        in [
                            "$mod, ${key}, workspace, ${toString (x + 1)}"
                            "$mod SHIFT, ${key}, movetoworkspace, ${toString (x + 1)}"
                            (lib.mkIf (x < 5)
                                "$mod Control, ${key}, workspace, ${toString (x + 6)}"
                            )
                            "$mod Control, ${key}, workspace, ${toString (x + 1)}"
                        ]
                    )
                        10)
                )
                ++ (
                    builtins.map (
                        x: "$mod, ${ builtins.elemAt x 0}, movefocus, ${builtins.elemAt x 1}\nbind=$mod Shift, ${builtins.elemAt x 0}, movewindow, ${builtins.elemAt x 1}"
                    )
                        [
                            ["h" "l"]
                            ["left" "l"]
                            ["j" "d"]
                            ["down" "d"]
                            ["k" "u"]
                            ["up" "u"]
                            ["l" "r"]
                            ["right" "r"]
                        ]
                );
            monitor =
                [
                    "eDP-1, highrr, 0x0, 1"
                    "HDMI-A-1, highrr, 1920x0, 1"
                ];
            workspace =
                (builtins.genList
                    (x : "${toString (x + 1)},monitor:eDP-1")
                    5
                )
                ++ (builtins.genList
                    (x : "${toString (x + 6)},monitor:HDMI-A-1")
                    5
                );
            
            
            input = {
                touchpad.natural_scroll = true;
                #touchpad.scroll_factor = 0.5;
                accel_profile = "flat";
                follow_mouse = true;
                kb_options = "caps:super";
                #sensitivity = 0.00;
            };
            decoration = {
                rounding = 10;
                drop_shadow = false;
            };
            animation = [
                "workspaces,1,5,easeOutQuint,slide"
            ];
            bezier = [
                "easeInOutCubic,0.65,0,0.35,1"
                "easeOutQuint,0.22,1,0.36,1"
            ];
            general = {
                #"col.inactive_border" = "rgb(2f2e43)";
                #"col.active_border" = "rgb(ab47bc)";
                border_size = 2;
                gaps_in = 6;
                gaps_out = 12;
            };
            windowrulev2 = [
                "opacity 0.8 override 0.8 override, title:Spotify$"
            ];
        };
    };

    home.packages = with pkgs; [
        ydotool
        xss-lock
        pamixer
        grimblast
        playerctl
        libsForQt5.spectacle
        inputs.hyprlock.packages.${system}.hyprlock
    ];
}
