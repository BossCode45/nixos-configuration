{
    pkgs,
    inputs,
    ...
} : {
    imports = [
        ../polybar
        ../rofi
        ../kitty
        inputs.YATwm.homeManagerModules.default
    ];
    home.packages = with pkgs; [
		i3lock
        xss-lock
		networkmanagerapplet
		flameshot
		picom
		nitrogen
        pamixer
        kitty
        alacritty
    ];

    xsession.windowManager.YATwm = {
        enable = true;
        package = inputs.YATwm.packages.x86_64-linux.YATwm;
        useEmacsBinds = true;
        quitKey = "s-g";
        swapMods = true;
        keybinds = let
            left = "h";
            right = "l";
            up = "k";
            down = "j";
        in {
            # Important
            "s-E" = "exit";
            "s-R" = "reload";

            # Directions
            "s-${left}" = "focChange left";
            "s-${right}" = "focChange right";
            "s-${up}" = "focChange up";
            "s-${down}" = "focChange down";

            # Tiling
            "s-t" = "toggle";
            "s-f" = "fullscreen";
            
            # Application shortcuts
            "s-d" = "bashSpawn rofi -i -show drun -disable-history";
            "s-D" = "bashSpawn prime-run rofi -i -show drun -disable-history";
            "s-g" = "bashSpawn ~/bin/rofi-passmenu";
            "s-RET" = "spawn alacritty";
            "s-r k" = "spawn kitty";
            "s-c" = "spawn firefox";
            "s-S--" = "bashSpawn emacsclient -c";
            "s-S" = "spawn flameshot gui";
            "s-x" = "spawn loginctl lock-session";
            "s-X" = "bashSpawn loginctl lock-session && systemctl suspend";
            "s-Q" = "kill";

            # Workspaces
            "s-1" = "changeWS 1";
            "s-S-1" = "wToWS 1";
            "s-2" = "changeWS 2";
            "s-S-2" = "wToWS 2";
            "s-3" = "changeWS 3";
            "s-S-3" = "wToWS 3";
            "s-4" = "changeWS 4";
            "s-S-4" = "wToWS 4";
            "s-5" = "changeWS 5";
            "s-S-5" = "wToWS 5";
            "s-6" = "changeWS 6";
            "s-S-6" = "wToWS 6";
            "s-7" = "changeWS 7";
            "s-S-7" = "wToWS 7";
            "s-8" = "changeWS 8";
            "s-S-8" = "wToWS 8";
            "s-9" = "changeWS 9";
            "s-S-9" = "wToWS 9";
            "s-0" = "changeWS 10";
            "s-S-0" = "wToWS 10";
            "s-p s" = "changeWS 11";
            "s-S-p s" = "wToWS 11";
        };
        workspaces = [
            {name = "1: A";}
            {name = "2: B";}
            {name = "3: C";}
            {name = "4: D";}
            {name = "5: E";}
            {name = "6: F"; monitorPriorities = [2 1];}
            {name = "7: G"; monitorPriorities = [2 1];}
            {name = "8: H"; monitorPriorities = [2 1];}
            {name = "9: I"; monitorPriorities = [2 1];}
            {name = "10: J"; monitorPriorities = [2 1];}
            {name = "S"; monitorPriorities = [1];}
        ];
        startup = [
            #{command = ".config/polybar/launch.sh"; once = false;}
            #{command = "picom --legacy-backends -fD 3"; once = false;}
            #{command = "xss-lock --transfer-sleep-lock -- i3lock -eti ~/Documents/lockscreen.png --nofork"; bash = false;}
            #{command = "nitrogen --restore";}
            #{command = "nm-applet"; once = false; bash = false;}
        ];
        #extraConfig = "bindmode normal\n" + (builtins.readFile ./config);
    };
}
