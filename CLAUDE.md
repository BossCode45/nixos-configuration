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

- **Flakes only see git-tracked files.** You must `git add` a new file before a rebuild can see it. This matters even more for `modules/`, which auto-imports files (see below).
- **`flake.lock` is gitignored**, so inputs aren't pinned in the repo.
- The **`YATwm` and `STK` inputs are `git+file://` paths** on this machine (`~/Documents/Coding/WM/YATwm`, `~/stk`). Evaluating either host needs them present. `nixnode` is always built from `nixy` and then pushed.
- Indentation is **4 spaces**. Multi-line `''` strings (shell scripts, configs) usually start at column 0 rather than following the Nix indentation. Match that.
- Leave `system.stateVersion` and `home.stateVersion` alone.

## Architecture

### Flake wiring (`flake.nix`)
Each host is assembled as `./modules` + `./hardware-setups/<hw>.nix` + `./computers/<host>.nix`. `nixy` also gets `./my-pkgs`, the home-manager NixOS module, and stylix. `inputs` is passed to every NixOS and home-manager module through `specialArgs`/`extraSpecialArgs`, so third-party modules are imported inline, e.g. `inputs.sops.nixosModules.sops`.

### `modules/`: custom option modules under the `teh-nix.*` namespace
`modules/default.nix` **auto-imports every `.nix` file in the directory recursively**, except `default.nix`. Both hosts import all of them, so each module has to be gated behind `lib.mkIf config.teh-nix.<name>.enable`, and a host turns on only what it needs:
- `teh-nix.nix`: nix settings, flakes, the registry/NIX_PATH pointing at the flake's nixpkgs, and `nh` cleanup (in place of `nix.gc`).
- `teh-nix.xorg`: X server, and pulls in the YATwm NixOS module. It enables `teh-nix.nvidia` by default.
- `teh-nix.nvidia`: PRIME offload with bus IDs, plus the `prime-run` wrapper.
- `teh-nix.services.cgit`: self-written cgit + nginx + git-over-ssh service, used on nixnode.

Add new reusable functionality here in the same `options`/`config = mkIf` pattern instead of putting it straight into a host file.

### `computers/`: per-host config
These are the old `configuration.nix` equivalents. They set the `teh-nix.*` toggles, sops secrets, networking, and the services for the host. The wireguard tunnel spans both files: `nixnode` is the hub (`10.100.0.1`, kernel wireguard), and `nixy` is the peer (`10.100.0.2`, a NetworkManager profile that gets its key from sops through `nm-file-secret-agent`).

### `home-manager/`: user `boss` on nixy
`home.nix` is the entry point and imports one directory per program (each has a `default.nix`; some ship raw dotfiles next to it, such as `i3/config`, `polybar/config.ini`, `waybar/config/`). Commented-out imports, like `hyprland`, are kept for switching back. Both `i3` and `YATwm` are imported, and `xsession.windowManager.command` is `mkForce`d to `"$@"` so the display manager decides which WM starts. Colors and fonts come from **stylix**, configured in `computers/nixy.nix`, so don't hardcode colors in program configs that stylix targets.

`claude-code` is pinned by overriding the nixpkgs package with a vendored manifest (`home-manager/claude-code-manifest-<version>.json`). To bump it, add the new manifest and update the filename in `home.nix`.

### `my-pkgs/`
`default.nix` is a NixOS module that adds an overlay (it currently provides `adom`). `stk-installers.nix` isn't part of the overlay: it's exposed directly as a flake package and served (currently commented out) from nixnode.

### `website/`
A static site: it copies `src/` into `$out/srv/www`. It's built as the flake package `teh-website`, and the `tehbox.org` vhost references it through `inputs.self.packages`.

### Secrets (sops-nix)
`secrets/general.yaml` is age-encrypted to both host keys listed in `.sops.yaml`. Each host decrypts with `/home/boss/.config/sops/age/keys.txt`. Secrets are declared per host in `sops.secrets` and consumed via `config.sops.secrets."<path>".path`.

### Git remotes
`github` (GitHub mirror) and `tehbox`/`nixnode` (the self-hosted cgit on the server).
