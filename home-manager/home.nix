{ pkgs, lib, inputs, ... }:
{
    imports = [
        ./shells/bash.nix
        ./emacs
        #./hyprland
        ./i3
        ./YATwm
        ./kitty
        inputs.spicetify-nix.homeManagerModules.default
        #inputs.stylix.homeManagerModules.stylix
    ];

    home = {
        stateVersion = "24.05";
        username = "boss";
        homeDirectory = "/home/boss";
    };
    
    # The home.packages option allows you to install Nix packages into your
    # environment.
    nixpkgs.config.allowUnfree = true;
    home.packages = with pkgs; [
        feh
        pass
        #spotify
        playerctl
        libqalculate
        libreoffice
        logisim-evolution
        thunderbird
        xdotool
        discord
        # (discord.override {
        #     withOpenASAR = true;
        # })
        mumble
        gimp
        bottom
        obs-studio
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
        unzip
        appimage-run
        lunar-client
        libnotify
        xclip
        (openttd-jgrpp.overrideAttrs (oldAttrs: rec {
            version = "0.63.3";
            src = fetchFromGitHub {
                owner = "JGRennison";
                repo = "OpenTTD-patches";
                rev = "jgrpp-${version}";
                hash = "sha256-853LbApHqQn+ucb7xjFDfohB0/T1h11o4voBgvgbpSI=";
            };
        }))
        (python3.withPackages (ps: with ps; [
            python-lsp-server
        ]))
        alacritty
        nyxt
        wireguard-tools
        brightnessctl
        inputs.nil.packages.${system}.default
        inputs.polymc.packages.${system}.default
        jre8
        inputs.zen-browser.packages."${system}".default
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

    services.dunst = {
        enable = true;
        settings = {
            global = {
                follow = "keyboard";
                frame_width = 0;
            };
        };
    };
    

    programs.firefox.enable = true;

    stylix.targets.spicetify.enable = false;
    stylix.targets.firefox.profileNames = [ "default"];
    
    programs.spicetify =
        let
            spicePkgs = inputs.spicetify-nix.legacyPackages.${pkgs.system};
        in
          {
              enable = true;
              enabledExtensions = with spicePkgs.extensions; [
                  fullAppDisplay
                  powerBar
                  addToQueueTop
              ];
              enabledCustomApps = with spicePkgs.apps; [
                  newReleases
                  lyricsPlus
                  betterLibrary
              ];
              theme = spicePkgs.themes.nightlight;
          };
    
    xsession.windowManager.command = lib.mkForce "$@";
}
