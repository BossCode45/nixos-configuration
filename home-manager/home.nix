{ pkgs, lib, inputs, ... }:
let
    claude-code-latest = pkgs.claude-code.override {
        manifest = lib.importJSON ./claude-code-manifest-2.1.282.json;
    };
in
{
    
    imports = [
        ./shells/bash.nix
        ./emacs
        #./hyprland
        ./i3
        # ./YATwm
        ./kitty
        inputs.spicetify-nix.homeManagerModules.default
        inputs.nixcord.homeModules.nixcord
        inputs.zen-browser.homeModules.twilight-official
        #inputs.stylix.homeManagerModules.stylix
    ];

    home = {
        stateVersion = "24.05";
        username = "boss";
        homeDirectory = "/home/boss";
    };
    
    # The home.packages option allows you to install Nix packages into your
    # environment.
    # nixpkgs.config.allowUnfree = true;
    home.packages = with pkgs; [
        feh
        pass
        # spotify
        playerctl
        libqalculate
        libreoffice
        hunspell
        hunspellDicts.en_AU
        logisim-evolution
        thunderbird
        xdotool
        discord
        # (discord.override {
        #     withOpenASAR = true;
        #     withVencord = true;
        # })
        # vesktop
        mumble
        gimp
        bottom
        xfce.thunar
        mpv
        man-pages
        man-pages-posix
        # (inputs.plover-flake.packages.${system}.plover.with-plugins (ps: with ps;[
        #     plover-dict-commands
        #     plover-console-ui
        #     plover-controller
        # ]))
        pavucontrol
        unzip zip
        appimage-run
        # lunar-client
        libnotify
        xclip
        (python3.withPackages (ps: with ps; [
            python-lsp-server
            numpy
            matplotlib
            jupyter
            jupytext
            pandas
            pydot
            scikit-learn
            nbdev
            pillow
        ]))
        graphviz
        alacritty
        # nyxt
        wireguard-tools
        brightnessctl
        # inputs.nil.packages.${system}.default
        nil
        #inputs.polymc.packages.${system}.default
        jre8
        #inputs.zen-browser.packages."${system}".default
        piper
        qbittorrent
        # sbcl
        superTuxKart
        typst
        sops
        ffmpeg
        ghc
        # hytale-launcher
        # inputs.hytale-launcher.packages.${pkgs.system}.default
        #adom
        flatpak
        deadlock-mod-manager
        nh
        claude-code-latest
        inputs.claude-desktop.packages.${system}.claude-desktop
        # openttd
    ];
    
    nix = {
        #package = pkgs.nix;
        settings.experimental-features = [ "nix-command" "flakes" ];
    };
    
    home.sessionVariables = {
        EDITOR = "emacsclient -c";
        MAKEFLAGS = " -j16 ";
        MOZ_ENABLE_WAYLAND = 1;
    };

    
    programs.home-manager.enable = true;

    programs.direnv = {
        enable = true;
        enableBashIntegration = true;
        nix-direnv.enable = true;
    };

    services.gpg-agent.enable = true;
    services.gpg-agent.pinentry.package = pkgs.pinentry-gtk2;

    services.dunst = {
        enable = true;
        settings = {
            global = {
                follow = "keyboard";
                frame_width = 0;
            };
        };
    };

    programs.obs-studio = {
        enable = true;

        # optional Nvidia hardware acceleration
        # package = (
        #     pkgs.obs-studio.override {
        #         cudaSupport = true;
        #     }
        # );

        plugins = with pkgs.obs-studio-plugins; [
            obs-pipewire-audio-capture
            input-overlay
        ];
    };

    # services.easyeffects.enable = true;

    services.pass-secret-service.enable = true;
    # Start with the X session rather than at boot, so it inherits DISPLAY/XAUTHORITY
    # and gpg can show the GTK pinentry. Otherwise apps get logged out.
    systemd.user.services.pass-secret-service = {
        Unit.After = [ "graphical-session.target" ];
        Unit.PartOf = lib.mkForce [ "graphical-session.target" ];
        Install.WantedBy = lib.mkForce [ "graphical-session.target" ];
    };


    programs.firefox = {
        enable = true;
    };
    programs.zen-browser = {
        enable = true;
        setAsDefaultBrowser = true;
    };

    # programs.nixcord = {
    #     enable = true;
    # };
    

    stylix.targets.spicetify.enable = true;
    stylix.targets.firefox.profileNames = [ "default"];
    stylix.targets.zen-browser.profileNames = [ "default" ];
    # stylix.targets.nixcord.enable = true;
    
    programs.spicetify =
        let
            spicePkgs = inputs.spicetify-nix.legacyPackages.${pkgs.system};
        in
          {
              enable = true;
              spotifyLaunchFlags = "--disable-gpu --disable-software-rasterizer";
              enabledExtensions = with spicePkgs.extensions; [
                  fullAppDisplay
                  powerBar
                  # addToQueueTop
                  loopyLoop
              ];
              enabledCustomApps = with spicePkgs.apps; [
                  newReleases
                  lyricsPlus
                  betterLibrary
              ];
              # theme = spicePkgs.themes.nightlight;
          };
    
    
    xsession.windowManager.command = lib.mkForce "$@";
}
