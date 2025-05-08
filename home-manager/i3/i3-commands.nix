{
    stdenv
}:
stdenv.mkDerivation {
    pname = "i3-commands";
    version = "0.0.1";

    srcs = builtins.path { name = "scripts"; path = ./scripts/.; };
    
    installPhase = ''
runHook preInstall
mkdir -p $out/bin
install -D -m 755 ./* $out/bin
runHook postInstall
'';
}
