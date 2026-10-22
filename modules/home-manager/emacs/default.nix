{ ... }:
{
	flake.modules.homeManager.emacs =
		{ pkgs, config, lib, ... }:
		let
			tex = (
				pkgs.texlive.combine {
					inherit (pkgs.texlive)
						scheme-medium
						dvisvgm
						dvipng # for preview and export as html
						# svg transparent
						etoolbox
						subfiles
						enumitem
						wrapfig
						amsmath
						ulem
						hyperref
						capt-of
						;
				}
			);
			myEmacs = (pkgs.emacsPackagesFor pkgs.emacs30).emacsWithPackages (
				# Packages listed here come from Nix; anything else in the config
				# is still installed by package.el (use-package-always-ensure)
				epkgs: with epkgs; [
					treesit-grammars.with-all-grammars
					# Not in nixpkgs; built here so nothing is cloned at startup
					(trivialBuild {
						pname = "trust-manager";
						version = "0-unstable-2026";
						src = pkgs.fetchFromGitHub {
							owner = "eshelyaron";
							repo = "trust-manager";
							rev = "0ff311bb59c9f1bb1ecdf413fa2bfa353bf389d7";
							hash = "sha256-hyWkMTCzIOdQ6NRjSdXAotEGsB76h2x5JvAg8X3fpug=";
						};
					})
					(trivialBuild {
						pname = "org-margin";
						version = "0.1.0";
						src = pkgs.fetchFromGitHub {
							owner = "rougier";
							repo = "org-margin";
							rev = "4013b59ff829903a7ab86b95593be71aa5c9b87d";
							hash = "sha256-2w9jc8Jd1McdyItqWJ+XXc62RIxsJ+Gro6Fi55EppY8=";
						};
					})
					ace-window
					consult
					corfu
					dashboard
					diminish
					direnv
					doom-themes
					ein
					eldoc-box
					embark
					embark-consult
					emms
					general
					glsl-mode
					haskell-mode
					helpful
					jabber
					kind-icon
					magit
					marginalia
					nerd-icons
					nix-mode
					orderless
					org-roam
					org-superstar
					pass
					posframe
					projectile
					rust-mode
					sudo-edit
					totp
					tree-sitter
					tree-sitter-langs
					treemacs
					treemacs-projectile
					typescript-mode
					typst-ts-mode
					vertico
					zoom-window
				]
			);
		in
		{
			# Config files are symlinked out of the store so they can be edited live
			home.file =
				let
					link = f: config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/nixos-configuration/modules/home-manager/emacs/config/${f}";
				in
				{
					".emacs.d/init.el".source = link "init.el";
					".emacs.d/config".source = link "config";
					".emacs.d/lisp".source = link "lisp";
					".emacs.d/gnu.png".source = link "gnu.png";
				};

			services.emacs = {
				enable = true;
				package = myEmacs;
			};

			# Restart the daemon on switch when the package or the elisp changes
			systemd.user.services.emacs.Unit = {
				X-RestartIfChanged = lib.mkForce true;
				X-Restart-Triggers = [ "${./config}" ];
			};

			home.packages = with pkgs; [
				# mu
				# emacsPackages.mu4e
				# isync
				ispell
				poppler-utils
				tex
				ghostscript
				haskell-language-server
				myEmacs
			];
		};
}
