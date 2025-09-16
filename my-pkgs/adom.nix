{ stdenv, fetchurl, autoPatchelfHook, makeDesktopItem, makeWrapper, ncurses5, libtinfo, SDL2, SDL2_image, SDL2_mixer, SDL2_net, SDL2_ttf, luajit} :

stdenv.mkDerivation rec {
    pname = "adom";
    version = "3.3.3";
    src = fetchurl {
        url = "https://sjc4.dl.dbolical.com/dl/2019/01/29/adom_noteye_linux_ubuntu_64_${version}.tar.gz?st=PcXL3PZSxDxr6H6v58PFfw==&e=1750223221";
        hash = "sha256-7c39tEPlrpWIL6QH0BIOLLrFFIlhEHPw5F3knMUh+BA=";
    };

    nativeBuildInputs = [
        autoPatchelfHook
        makeWrapper
    ];
    
    buildInputs = [
        (ncurses5.override { unicodeSupport = false; })
        ncurses5
        SDL2
        SDL2_image
        SDL2_mixer
        SDL2_net
        SDL2_ttf
        luajit
        stdenv.cc.cc.lib
    ];

    sourceRoot = "adom";
    installPhase = let desktopEntry = makeDesktopItem {
        name = "adom";
        desktopName = "ADOM";
        exec = "OUT_DIR/bin/adom";
        #path = "OUT_DIR/share";
    }; in ''
    runHook preInstall
    install -m755 -D adom $out/bin/adom
    wrapProgram $out/bin/adom \
                --chdir $out/share
    install -m644 -D lib/libnoteye.so $out/lib/libnoteye.so
    mkdir -p $out/share
    cp -r common $out/share/
    cp -r docs $out/share/
    cp -r games $out/share/
    cp -r gfx $out/share/
    cp -r licenses $out/share/
    cp -r sound $out/share/
    mkdir -p $out/share/applications
    sed -e "s|OUT_DIR|$out|g" ${desktopEntry}/share/applications/adom.desktop > $out/share/applications/adom.desktop
    runHook postInstall
'';
}
