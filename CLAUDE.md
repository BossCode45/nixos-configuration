# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What this is

A flake-based NixOS + home-manager configuration (nixpkgs/home-manager/stylix pinned to the `26.05` release branches) that defines two hosts:

- **`nixy`**: the desktop/laptop (ASUS TUF, Intel + NVIDIA PRIME offload). Includes home-manager for user `boss`, stylix theming, and the X11 window managers.
- **`nixnode`**: a Linode VPS serving `tehbox.org` (nginx vhosts, ACME, the mailserver, cgit at `git.tehbox.org`, the wireguard hub, ZNC, a SuperTuxKart server, and a goaccess dashboard). There is no home-manager here.

## Commands

```bash
# Rebuild and switch the local machine (nixy). Bash alias: flake-rebuild
sudo nixos-rebuild switch --flake ~/nixos-configuration      # or: nh os switch ~/nixos-configuration

# Evaluate/build without switching (the quickest way to check a change)
nixos-rebuild build --flake .#nixy
nix build .#nixosConfigurations.nixnode.config.system.build.toplevel

# Deploy the server
./server-rebuild.sh                  # nixos-rebuild --target-host to nixnode
deploy .#nixnode                     # alternative via deploy-rs (interactive sudo)

# Flake checks (deploy-rs schema checks)
nix flake check

# Standalone packages exposed by the flake
nix build .#teh-website
nix build .#stk-installers

# Secrets
sops secrets/general.yaml
```

There are no tests or linter. "Does it evaluate/build" is the check. `nil` is installed as the Nix LSP.

## Gotchas

- **Flakes only see git-tracked files.** You must `git add` a new file before a rebuild can see it. This matters even more here, because `modules/` is auto-imported by import-tree (see below).
- **`flake.lock` is tracked.** Run `nix flake lock` after adding an input.
- The **`STK` input is a `git+file://` path** (`~/stk`), and evaluating the flake needs it present. The `YATwm` input (`~/Documents/Coding/WM/YATwm`) is currently commented out; `homeManager.YATwm` references it lazily, so that's fine as long as nothing imports that module. `nixnode` is always built from `nixy` and then pushed.
- Indentation is **4 spaces**. Multi-line `''` strings (shell scripts, configs) usually start at column 0 rather than following the Nix indentation. Match that.
- Leave `system.stateVersion` and `home.stateVersion` alone.

## Architecture

### Dendritic pattern (flake-parts + import-tree)
`flake.nix` only declares inputs and runs `inputs.flake-parts.lib.mkFlake { inherit inputs; } (inputs.import-tree ./modules)`. **Every `.nix` file under `modules/` is a flake-parts module** and is auto-imported. A file whose name has a path component starting with `_` is skipped. Each file exports exactly one thing:
- NixOS modules: `flake.modules.nixos.<name>`
- home-manager modules: `flake.modules.homeManager.<name>`
- packages: `perSystem.packages.<name> = pkgs.callPackage (<fn>) { };`
- hosts: `flake.nixosConfigurations.<host>`

The original module goes inside, wrapped like this:
```nix
{ inputs, config, ... }:
let
    nixos = config.flake.modules.nixos;
    hm = config.flake.modules.homeManager;
in
{
    flake.modules.nixos.<name> =
        { config, lib, pkgs, ... }:
        { ... };
}
```
**There are no `specialArgs`.** Inner modules use the outer-captured `inputs`, so `inputs` must never be added back to an inner argument list. Modules import each other by reference (`hm.polybar`, `nixos.teh-nix`), not by relative path. Relative paths are only for asset files that sit next to the module, such as `./config` and `./scripts`. Paths to the repo-root `secrets/` and `wallpaper.png` are `../../`.

`modules/flake-parts.nix` imports `flake-parts.flakeModules.modules` and sets `systems`. `modules/deploy.nix` holds `flake.deploy.nodes.nixnode` and the deploy-rs `checks`.

### `modules/teh-nix/`: custom option modules under the `teh-nix.*` namespace
All four files define **`flake.modules.nixos.teh-nix`**. These deferred modules merge into one module, and both hosts import it, so each feature has to be gated behind `lib.mkIf config.teh-nix.<name>.enable`. A host turns on only what it needs:
- `teh-nix.nix`: nix settings, flakes, the registry/NIX_PATH pointing at the flake's nixpkgs, and `nh` cleanup (in place of `nix.gc`).
- `teh-nix.xorg`: X server, with a YATwm NixOS module hook (commented out). It enables `teh-nix.nvidia` by default.
- `teh-nix.nvidia`: PRIME offload with bus IDs, plus the `prime-run` wrapper.
- `teh-nix.services.cgit`: self-written cgit + nginx + git-over-ssh service, used on nixnode.

Add new reusable functionality here in the same `options`/`config = mkIf` pattern instead of putting it straight into a host file.

### `modules/computers/`: per-host config
Each file defines both `flake.modules.nixos.<host>` and `flake.nixosConfigurations.<host>`. These are the old `configuration.nix` equivalents, and their `imports` do the host assembly: `nixos.teh-nix`, the hardware module (`nixos.tuf` / `nixos.linode` from `modules/hardware-setups/`), and the `inputs.*` modules. `nixy` additionally imports `nixos.my-pkgs`, home-manager (`home-manager.users.boss = hm.boss`) and stylix. Host files set the `teh-nix.*` toggles, sops secrets, networking and the host's services. The wireguard tunnel spans both files: `nixnode` is the hub (`10.100.0.1`, kernel wireguard), and `nixy` is the peer (`10.100.0.2`, a NetworkManager profile that gets its key from sops through `nm-file-secret-agent`).

### `modules/home-manager/`: user `boss` on nixy
`home.nix` exports `homeManager.boss`, the entry point. There is one directory per program, each with a `default.nix` exporting `homeManager.<dir>`; some ship raw dotfiles next to it, such as `i3/config`, `polybar/config.ini` and `waybar/config/`. `shells/bash.nix` exports `homeManager.bash`. Commented-out imports, like `hm.hyprland`, are kept for switching back. `xsession.windowManager.command` is `mkForce`d to `"$@"` so the display manager decides which WM starts. Colors and fonts come from **stylix**, configured in `computers/nixy.nix`, so don't hardcode colors in program configs that stylix targets.

`i3/i3-commands.nix` and `i3/rofi-passmenu.nix` are flake packages, and the i3 module uses them through `inputs.self.packages.${pkgs.stdenv.hostPlatform.system}`.

`claude-code` is pinned by overriding the nixpkgs package with a vendored manifest (`modules/home-manager/claude-code-manifest-<version>.json`). To bump it, add the new manifest and update the filename in `home.nix`.

### `modules/my-pkgs/`
`adom.nix` and `stk-installers.nix` are flake packages. `default.nix` exports `nixos.my-pkgs`, an overlay that exposes `inputs.self.packages.<system>.adom` as `pkgs.adom`. `stk-installers` is served (currently commented out) from nixnode.

### `modules/website/`
A static site: it copies `src/` into `$out/srv/www`. It's built as the flake package `teh-website`, and the `tehbox.org` vhost references it through `inputs.self.packages`.

### Secrets (sops-nix)
`secrets/general.yaml` is age-encrypted to both host keys listed in `.sops.yaml`. Each host decrypts with `/home/boss/.config/sops/age/keys.txt`. Secrets are declared per host in `sops.secrets` and consumed via `config.sops.secrets."<path>".path`.

### Git remotes
`github` (GitHub mirror) and `tehbox`/`nixnode` (the self-hosted cgit on the server).
