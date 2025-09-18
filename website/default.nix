{ stdenv, ... }:
stdenv.mkDerivation {
    pname = "TehWebsite";
    version = "0.0.1";

    src = ./src;

    installPhase = ''
mkdir -p $out/srv/www
cp -r ./* $out/srv/www
'';
}
