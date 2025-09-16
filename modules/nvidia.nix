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

    services.xserver.videoDrivers = [ "nvidia" ];

    environment.systemPackages = [ nvidia-offload ];
}
