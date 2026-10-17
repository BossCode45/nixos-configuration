{
    perSystem =
        { pkgs, ... }:
        {
            packages.i3-commands = pkgs.callPackage (
                {
                    stdenv,
                    lib
                }:
                stdenv.mkDerivation {
                    pname = "i3-commands";
                    version = "0.0.1";

                    srcs = lib.cleanSourceWith {
                        src = ./scripts;
                        filter = path: type: baseNameOf path != "rofi-passmenu";
                    };

                    installPhase = ''
        runHook preInstall
        mkdir -p $out/bin
        install -D -m 755 ./* $out/bin
        runHook postInstall
    '';
                }
            ) { };
        };
}
