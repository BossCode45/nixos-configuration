{
    perSystem =
        { pkgs, ... }:
        {
            packages.stk-installers = pkgs.callPackage (
                { stdenv, fetchurl, lib, writeText, ... }:
                stdenv.mkDerivation rec {
                    pname = "stk-installers";
                    version = "0.1.0";

                    srcs = let
                        releaseHashes = {
                            #"installer-aarch64.exe" = "sha256-orLoDvW+fUDucqY4KcC0DQ4JbA2LaG3RQtaBEjtG6HU=";
                            #"installer-i686.exe" = "sha256-knC7XF6OeY/dQ2VnyjYm+IlJxU8g6s/S395Nr4HZ6Jk=";
                            # "installer-x86_64.exe" = "sha256-oSYOu3PdnaE+w+N/Um8p5JSztmwAwF/XB2ezCkSX2V4=";
                            # "linux-arm64.tar.gz" = "sha256-lhtLaRtEVHzcrae6OdrRVhpufnZskLIsot8foYqi5Hc=";
                            #"linux-armv7.tar.gz" = "sha256-jQYR2wkIu1j7c5xEfzdIa9fnQFU1wNKAVq35NZB/BzA=";
                            # "linux-x86.tar.gz" = "sha256-sT57jnRV7Wa4qC8p1/fOTwXfelM66fRckdfQvqMqOOs=";
                            "linux-x86_64.tar.gz" = "sha256-VwkLbCFj62kfIBBK6XEiBKy7ToNBBZ3uCl/1MV78QBs=";
                            # "mac-signed.zip" = "sha256-wmas24pjo/4w9SZS2bdJ9b66Sr655UOC+7k0sAxTswM=";
                            # "src.tar.gz" = "sha256-M8+IQeT/QILYC5JIAUKVu76mHRRoPobf8QDjq497J8s=";
                            # "win.zip" = "sha256-nffi1n6FYhJ6O7YzAw8b1O53+p5/CuEQiXRzAlr4rNw=";
                        };
                    in
                      lib.attrsets.mapAttrsToList (release: hash: fetchurl {
                          url = "https://github.com/supertuxkart/stk-code/releases/download/1.5/SuperTuxKart-1.5-${release}";
                          sha256 = hash;
                      }) releaseHashes
                      ++ [(writeText "hashes.txt" (builtins.concatStringsSep "\n" (lib.attrsets.mapAttrsToList (release: hash: "SuperTuxKart-1.5-${release} ${hash}") releaseHashes)))];

                    sourceRoot = ".";

                    unpackPhase = ":";

                    installPhase = ''
mkdir -p $out/srv/www
for srcFile in $srcs; do
    cp $srcFile "$out/srv/www/$(stripHash $srcFile)"
done
'';
                }
            ) { };
        };
}
