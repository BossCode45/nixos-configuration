# Edit this configuration file to define what should be installed on
# your system. Help is available in the configuration.nix(5) man page, on
# https://search.nixos.org/options and in the NixOS manual (`nixos-help`).

{ config, lib, pkgs, inputs, ... }:

{
    imports =
        [ # Include the results of the hardware scan.
            ../modules/nix.nix
            inputs.STK.nixosModules.default
            inputs.sops.nixosModules.sops
        ];

    # Use the GRUB 2 boot loader.
    boot.loader.grub.enable = true;
    # boot.loader.grub.efiSupport = true;
    # boot.loader.grub.efiInstallAsRemovable = true;
    # boot.loader.efi.efiSysMountPoint = "/boot/efi";
    # Define on which hard drive you want to install Grub.
    # boot.loader.grub.device = "/dev/sda"; # or "nodev" for efi only

    networking.hostName = "nixos"; # Define your hostname.
    # Pick only one of the below networking options.
    # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.
    networking.networkmanager.enable = true;  # Easiest to use and most distros use this by default.

    # Set your time zone.
    # time.timeZone = "Europe/Amsterdam";

    # Configure network proxy if necessary
    # networking.proxy.default = "http://user:password@proxy:port/";
    # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

    # Select internationalisation properties.
    # i18n.defaultLocale = "en_US.UTF-8";
    # console = {
    #   font = "Lat2-Terminus16";
    #   keyMap = "us";
    #   useXkbConfig = true; # use xkb.options in tty.
    # };

    # Enable the X11 windowing system.
    # services.xserver.enable = true;

    security.sudo.wheelNeedsPassword = false;

    sops.defaultSopsFile = ../secrets/general.yaml;
    sops.defaultSopsFormat = "yaml";
    
    sops.age.keyFile = "/home/boss/.config/sops/age/keys.txt";

    sops.secrets = {
        #"wg/nixy/pub" = { };
        "wg/nixnode/priv" = { };
    };

    networking.firewall = {
        enable = true;
        allowedTCPPorts = [ 80 443 ];
        allowedUDPPorts = [ 51820 ];
    };

    # Wireguard
    networking = {
        nat = {
            enable = true;
            externalInterface = "eth0";
            internalInterfaces = [ "wg0" ];
        };

        wireguard.interfaces.wg0 = {
            ips = [ "10.100.0.1/24" ];
            listenPort = 51820;
            
            postSetup = ''
${pkgs.iptables}/bin/iptables -t nat -A POSTROUTING -s 10.100.0.0/24 -o eth0 -j MASQUERADE
'';
            postShutdown = ''
${pkgs.iptables}/bin/iptables -t nat -D POSTROUTING -s 10.100.0.0/24 -o eth0 -j MASQUERADE
'';

            privateKeyFile = config.sops.secrets."wg/nixnode/priv".path;

            peers = [
                {
                    name = "nixy";
                    publicKey = "FMkFU9k+YeCvj48+WDVglySgoncbITqkS//o2e+TClY=";
                    allowedIPs = [ "10.100.0.2/32" ];
                }
            ];
        };
    };

    services.httpd = {
        enable = true;
        virtualHosts."172.105.172.191" = {
            documentRoot = "/srv/httpd";
        };
    };
    
    services.openssh = {
        enable = true;
        settings.PermitRootLogin = "no";
        settings.PasswordAuthentication = false;
    };

    services.superTuxKarts = {
        enable = true;
	    port = 2757;
        serverOptions = {
            server-name = "LUG STK server";
            server-mode = 0;
            server-difficulty = 3;
	        private-server-password = "lug@uoa";
            motd = "Server for LUG@UoA\nChampionship coming soon!";
        };
    };

    users.users.boss = {
        isNormalUser = true;
        extraGroups = [ "wheel" "networkmanager" ]; # Enable ‘sudo’ for the user.
        home = "/home/boss";
        openssh.authorizedKeys.keys = [ "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIJOukEKExoF6vr3vciQN8pBdd4FtZtRzqIGFJrUvllOY boss@nixy" ];
    };

    environment.systemPackages = with pkgs; [
        vim
        emacs
        inetutils
        mtr
        sysstat
        git
    ];
    

    # Open ports in the firewall.
    # networking.firewall.allowedTCPPorts = [ ... ];
    # networking.firewall.allowedUDPPorts = [ ... ];
    # Or disable the firewall altogether.
    # networking.firewall.enable = false;

    networking.usePredictableInterfaceNames = false;
    networking.useDHCP = false;
    networking.interfaces.eth0.useDHCP = true;

    # Copy the NixOS configuration file and link it from the resulting system
    # (/run/current-system/configuration.nix). This is useful in case you
    # accidentally delete configuration.nix.
    # system.copySystemConfiguration = true;

    # This option defines the first version of NixOS you have installed on this particular machine,
    # and is used to maintain compatibility with application data (e.g. databases) created on older NixOS versions.
    #
    # Most users should NEVER change this value after the initial install, for any reason,
    # even if you've upgraded your system to a new NixOS release.
    #
    # This value does NOT affect the Nixpkgs version your packages and OS are pulled from,
    # so changing it will NOT upgrade your system - see https://nixos.org/manual/nixos/stable/#sec-upgrading for how
    # to actually do that.
    #
    # This value being lower than the current NixOS release does NOT mean your system is
    # out of date, out of support, or vulnerable.
    #
    # Do NOT change this value unless you have manually inspected all the changes it would make to your configuration,
    # and migrated your data accordingly.
    #
    # For more information, see `man configuration.nix` or https://nixos.org/manual/nixos/stable/options#opt-system.stateVersion .
    system.stateVersion = "25.05"; # Did you read the comment?

}
