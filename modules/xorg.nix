{ config, lib, pkgs, inputs, ... }:
{
    imports = [
        ./nvidia.nix
        inputs.YATwm.nixosModules.YATwm
    ];
    
    options.teh-nix.xorg = with lib; {
        enable = mkEnableOption "Enable xorg";
        nvidia = mkOption {
            type = types.bool;
            default = true;
            description = "Enable nvidia with xorg";
        };
    };
    
    config = lib.mkIf config.teh-nix.xorg.enable {

        teh-nix.nvidia.enable = lib.mkIf config.teh-nix.xorg.nvidia (lib.mkDefault true);
        
        services.xserver = {
	        enable = true;

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

            windowManager.YATwm = {
                enable = true;
                package = inputs.YATwm.packages.x86_64-linux.YATwm;
            };
	    };
        programs.i3lock.enable = true;

        services.displayManager = {
		    #defaultSession = "none+i3";
		    sddm.enable = true;
            #sddm.theme = "catppuccin-macchiato";
            # ly.enable = true;
	    };

        
	    services.xserver.xkb.layout = "us";
	    services.xserver.xkb.options = "caps:super";
    };
}
