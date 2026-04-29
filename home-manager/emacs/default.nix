{ pkgs, config, ... } :
let
    tex = (pkgs.texlive.combine {
        inherit (pkgs.texlive) scheme-medium
            dvisvgm dvipng # for preview and export as html
            # svg transparent
            etoolbox
            subfiles
            enumitem
            wrapfig amsmath ulem hyperref capt-of;
    });
    myEmacs = (pkgs.emacsPackagesFor pkgs.emacs30).emacsWithPackages (epkgs: with epkgs; [
        vterm
        treesit-grammars.with-all-grammars
    ]);
in
{
    services.emacs = {
        enable = true;
        package = myEmacs;
    };
    
    home.packages = with pkgs; [
        mu
        emacsPackages.mu4e
        isync
        ispell
        poppler-utils
        tex
        ghostscript
        haskell-language-server
        myEmacs
    ];
}
