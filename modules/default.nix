{ lib, ... }:
{
    imports = lib.filter 
        (n: (lib.strings.hasSuffix ".nix" n) && !(lib.strings.hasSuffix "default.nix" n))
        (lib.filesystem.listFilesRecursive ./.);
}
