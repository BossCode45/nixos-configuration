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
- Indentation is **tabs** (`tabify-nix.py` converted the tree; the snippet below uses spaces only for display). Multi-line `''` strings (shell scripts, configs) usually start at column 0 rather than following the Nix indentation. Match that.
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

### `modules/home-manager/emacs/`: Emacs (`homeManager.emacs`)
`default.nix` builds `myEmacs` (`emacsWithPackages` on `emacs30`), runs it as `services.emacs` (daemon, used via `emacsclient -c`), and installs the tooling it needs (texlive, ispell, haskell-language-server...). The elisp lives in `emacs/config/` (`init.el`, `config/teh-config-*.el`, `lisp/`, `gnu.png`), and each of those is linked into `~/.emacs.d` with `config.lib.file.mkOutOfStoreSymlink`, pointing at this repo checkout. **Editing elisp needs no rebuild**; just restart Emacs. Only new links or Nix package changes need a switch. A switch restarts `emacs.service` whenever the tracked elisp (`X-Restart-Triggers` on the `./config` store copy) or the Emacs package changed, so unsaved buffers are lost. The rest of `~/.emacs.d` (elpa/, eln-cache/, org-roam.db, recentf...) is untracked runtime state.

Packages are **hybrid**:
- Anything in the `epkgs` list comes from Nix. emacsWithPackages puts these on `package-directory-list`, so `use-package-always-ensure t` treats them as installed and doesn't download them.
- Every other `use-package` in the config is still installed at runtime by package.el into `~/.emacs.d/elpa`. ghostel and popterm are deliberately kept there because nixpkgs lags far behind upstream.
- To move a package to Nix: add it to `epkgs`, switch, then delete its `~/.emacs.d/elpa/<pkg>-*` dir. package.el loads the highest version, so a stale elpa copy would win.
- Packages that aren't in nixpkgs (trust-manager, org-margin) are built inline with `trivialBuild` + `fetchFromGitHub`, pinned by rev and hash, and their `use-package` uses `:ensure nil` (trivialBuild packages are invisible to package.el).
- **Don't use `:vc` or package-vc for new packages.** It fetches `elpa-packages.eld` from elpa.gnu.org on startup. elpa.gnu.org is unreachable over IPv6 from nixy, and Emacs has no IPv4 fallback, so the daemon hangs until systemd's 90s start timeout kills it and restarts it in a loop. claude-code-ide is the one package-vc install left; it's already installed, but reinstalling it would hit the same hang.
- straight.el is no longer used. use-package is the built-in Emacs 30 one.

Other notes:
- Customize writes to an untracked `~/.emacs.d/custom.el` (`custom-file` in `init.el`), so trust-manager paths and other machine-local settings stay out of this public repo. Don't put `custom-set-variables` back in `init.el`.
- mu4e is disabled: the `require` and the `C-z e` binding in `teh-config-keybinds.el` are commented out, as are `mu`, `mu4e` and `isync` in `default.nix`. `teh-config-mu4e.el` is kept but not loaded, and `.mbsyncrc` is intentionally not in the repo.
- To check the config without switching, run `nixos-rebuild build --flake .#nixy`, then `result/etc/profiles/per-user/boss/bin/emacs --batch -l ~/.emacs.d/init.el`.

### `modules/my-pkgs/`
`adom.nix` and `stk-installers.nix` are flake packages. `default.nix` exports `nixos.my-pkgs`, an overlay that exposes `inputs.self.packages.<system>.adom` as `pkgs.adom`. `stk-installers` is served (currently commented out) from nixnode.

### `modules/website/`
A static site: it copies `src/` into `$out/srv/www`. It's built as the flake package `teh-website`, and the `tehbox.org` vhost references it through `inputs.self.packages`.

### Secrets (sops-nix)
`secrets/general.yaml` is age-encrypted to both host keys listed in `.sops.yaml`. Each host decrypts with `/home/boss/.config/sops/age/keys.txt`. Secrets are declared per host in `sops.secrets` and consumed via `config.sops.secrets."<path>".path`.

### Git remotes
`github` (GitHub mirror) and `tehbox`/`nixnode` (the self-hosted cgit on the server).
