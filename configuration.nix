# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, inputs, ... }:

let
    nvidia-offload = pkgs.writeShellScriptBin "prime-run" ''
export __NV_PRIME_RENDER_OFFLOAD=1
export __NV_PRIME_RENDER_OFFLOAD_PROVIDER=NVIDIA-G0
export __GLX_VENDOR_LIBRARY_NAME=nvidia
export __VK_LAYER_NV_optimus=NVIDIA_only
exec "$@"
'';
in
{
    imports =
	    [ # Include the results of the hardware scan.
		    ./hardware-configuration.nix
            inputs.YATwm.nixosModules.default
            #inputs.spicetify-nix.nixosModules.default
	    ];


    nix.nixPath = [ "/etc/nix/path" ];
    nix.registry.nixpkgs.flake = inputs.nixpkgs;
    environment.etc."nix/path/nixpkgs".source = inputs.nixpkgs;

    
    # Use the systemd-boot EFI boot loader.
    boot = {
        loader.grub.enable = true;
        loader.grub.device = "nodev";
        loader.grub.efiSupport = true;
	loader.grub.enableCryptodisk = true;
        # loader.grub.useOSProber = true;
        loader.efi.canTouchEfiVariables = true;
        kernel.sysctl."kernel.sysrq" = 502;
        plymouth.enable = true;
    };


    networking.hostName = "nixy"; # Define your hostname.
    # Pick only one of the below networking options.
    # networking.wireless.enable = true;	# Enables wireless support via wpa_supplicant.
    networking.networkmanager.enable = true;	# Easiest to use and most distros use this by default.

    # Set your time zone.
    time.timeZone = "NZ";

    # Configure network proxy if necessary
    # networking.proxy.default = "http://user:password@proxy:port/";
    # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

    # Select internationalisation properties.
    i18n.defaultLocale = "en_US.UTF-8";
    console = {
	    font = "Lat2-Terminus16";
	    #keyMap = "us";
	    #useXkbConfig = true; # use xkbOptions in tty.
    };

    nixpkgs.config.allowUnfree = true;
    hardware.graphics.enable = true;
    hardware.nvidia.modesetting.enable = true;
    hardware.nvidia.open = true;
    hardware.nvidia.prime = {
	    offload.enable = true;

	    nvidiaBusId = "PCI:1:0:0";
	    intelBusId = "PCI:5:0:0";
    };
    hardware.nvidia.package = config.boot.kernelPackages.nvidiaPackages.stable;

    # Enable the X11 windowing system.
    services.xserver = {
	    enable = true;
	    videoDrivers = [ "nvidia" ];

	    desktopManager = {
		    xterm.enable = false;
            #default = "none";
	    };
        
        deviceSection = ''
                      Option "DRI" "2"
                      Option "TearFree" "true"
                      '';

	    windowManager.i3 = {
		    enable = true;
		    package = pkgs.i3-gaps;
	    };

        #windowManager.YATwm = {
        #    enable = true;
        #    package = inputs.YATwm.packages.x86_64-linux.YATwm;
        #};
	};
    programs.hyprland = {
        enable = true;
        #package = inputs.hyprland.packages.${pkgs.system}.hyprland;
        #portalPackage = inputs.hyprland.packages.${pkgs.system}.xdg-desktop-portal-hyprland;
    };
    services.displayManager = {
		#defaultSession = "none+i3";
		#sddm.enable = true;
        #sddm.theme = "catppuccin-macchiato";
        #ly.enable = true;
        
	};
	services.xserver.displayManager.lightdm.enable = true;

	# Configure keymap in X11
	services.xserver.xkb.layout = "us";
	services.xserver.xkb.options = "caps:super";


    security.pam.services.swaylock = {};

	# Enable CUPS to print documents.
	services.printing.enable = true;
    services.printing.drivers = [ pkgs.hplip ];
    services.avahi = {
        enable = true;
        nssmdns4 = true;
        openFirewall = true;
    };

	# Enable sound.
	#sound.enable = true;
	services.pipewire =
	    {
		    enable = true;
		    alsa.enable = false;
		    alsa.support32Bit = false;
		    pulse.enable = true;
	    };

    services.upower.enable = true;

	# Enable touchpad support (enabled default in most desktopManager).
    security.rtkit.enable = true;
    services.libinput = {
        enable = true;
		mouse = {
			accelProfile = "flat";
		};
	};

	# Define a user account. Don't forget to set a password with ‘passwd’.
	users.users.boss = {
	    isNormalUser = true;
	    extraGroups = [ "wheel" "networkmanager" "input" "uinput" ];
	};

	fonts.packages = with pkgs; [
	    (nerdfonts.override { fonts = [ "Cousine" ]; })
	];

	# List packages installed in system profile. To search, run:
	# $ nix search wget
    nix = {
        settings = {
            experimental-features = [ "nix-command" "flakes" ];
            auto-optimise-store = true;
            
            trusted-users = [ "boss" ];

            substituters = [
                "https://cache.nixos.org"
            ];

            trusted-public-keys = [
                "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
            ];
        };
        gc = {
            automatic = true;
            dates = "weekly";
            options = "--delete-older-than +5";
        };
        optimise.automatic = true;
    };
	environment.systemPackages = with pkgs;
	    [
		    nvidia-offload
		    vim
		    firefox
		    pfetch
		    neofetch
            pinentry-gtk2
            git
	    ];
    documentation.dev.enable = true;

    programs.steam.enable = true;
    hardware.graphics.enable32Bit = true;
    nixpkgs.config.packageOverrides = pkgs: {
        steam = pkgs.steam.override {
            extraPkgs = pkgs: with pkgs; [
                pango
                # gamemode
                harfbuzz
            ];
        };
    };

	# Some programs need SUID wrappers, can be configured further or are
	# started in user sessions.
	# programs.mtr.enable = true;
	programs.gnupg = {
        agent = {
	        enable = true;
            pinentryPackage = pkgs.pinentry-gtk2;
        };
	    #	 enableSSHSupport = true;
	};

    hardware.bluetooth.enable = true; # enables support for Bluetooth
    hardware.bluetooth.powerOnBoot = true; # powers up the default Bluetooth controller on boot
    services.blueman.enable = true;

    systemd.tmpfiles.rules = [
        "f /var/lib/systemd/linger/boss" # enables lingering
    ];

    stylix = {
        enable = true;
        
        base16Scheme = "${pkgs.base16-schemes}/share/themes/material-palenight.yaml";

        image = ./wallpaper.png;
        targets.grub.useImage = true;

        opacity = {
            terminal = 0.8;
        };

        polarity = "dark";

        fonts = {
            monospace = {
                package = pkgs.nerdfonts.override { fonts = [ "Cousine" ]; };
                name = "Cousine Nerd Font Mono";
            };

            serif = {
                package = pkgs.dejavu_fonts;
                name = "DejaVu Serif";
            };

            sansSerif = {
                package = pkgs.dejavu_fonts;
                name = "DejaVu Sans";
            };

            emoji = {
                package = pkgs.noto-fonts-emoji;
                name = "Noto Color Emoji";
            };
            
            sizes = {
                terminal = 10;
                applications = 10;
                desktop = 10;
                popups = 10;
            };
        };

        cursor = {
            package = pkgs.nordzy-cursor-theme;
            name = "Nordzy-cursors";
            size = 20;
        };
    };

	# Copy the NixOS configuration file and link it from the resulting system
	# (/run/current-system/configuration.nix). This is useful in case you
	# accidentally delete configuration.nix.
	# system.copySystemConfiguration = true;

	# This value determines the NixOS release from which the default
	# settings for stateful data, like file locations and database versions
	# on your system were taken. It‘s perfectly fine and recommended to leave
	# this value at the release version of the first install of this system.
	# Before changing this value read the documentation for this option
	# (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
	system.stateVersion = "24.05"; # Did you read the comment?

}

