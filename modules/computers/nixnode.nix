{ inputs, config, ... }:
let
	nixos = config.flake.modules.nixos;
in
{
	flake.nixosConfigurations.nixnode = inputs.nixpkgs.lib.nixosSystem {
		modules = [ nixos.nixnode ];
	};

	flake.modules.nixos.nixnode =
		# Edit this configuration file to define what should be installed on
		# your system. Help is available in the configuration.nix(5) man page, on
		# https://search.nixos.org/options and in the NixOS manual (`nixos-help`).

		{
			config,
			lib,
			pkgs,
			...
		}:

		{
			imports = [
				nixos.teh-nix
				nixos.linode
				inputs.STK.nixosModules.default
				inputs.sops.nixosModules.sops
				inputs.nixos-mailserver.nixosModules.default
				inputs.neodrive-website.nixosModules.default
			];

			teh-nix.nix.enable = true;

			# Use the GRUB 2 boot loader.
			boot.loader.grub.enable = true;
			# boot.loader.grub.efiSupport = true;
			# boot.loader.grub.efiInstallAsRemovable = true;
			# boot.loader.efi.efiSysMountPoint = "/boot/efi";
			# Define on which hard drive you want to install Grub.
			# boot.loader.grub.device = "/dev/sda"; # or "nodev" for efi only

			networking.hostName = "nixnode"; # Define your hostname.
			# Pick only one of the below networking options.
			# networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.
			networking.networkmanager.enable = true; # Easiest to use and most distros use this by default.

			# Set your time zone.
			time.timeZone = "NZ";

			# Configure network proxy if necessary
			# networking.proxy.default = "http://user:password@proxy:port/";
			# networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

			# Select internationalisation properties.
			# i18n.defaultLocale = "en_US.UTF-8";
			# console = {
			#   font = "Lat2-Terminus16";
			#   keyMap = "us";
			#   useXkbConfcpfig = true; # use xkb.options in tty.
			# };

			# Enable the X11 windowing system.
			# services.xserver.enable = true;

			security.sudo.wheelNeedsPassword = false;

			sops.defaultSopsFile = ../../secrets/general.yaml;
			sops.defaultSopsFormat = "yaml";

			sops.age.keyFile = "/home/boss/.config/sops/age/keys.txt";

			sops.secrets = {
				#"wg/nixy/pub" = { };
				"wg/nixnode/priv" = { };
				"acme/linode" = {
					owner = "acme";
					mode = "440";
				};
				"mail/boss" = { };
				"nginx/dashboard-htpasswd" = {
					owner = "nginx";
					mode = "400";
				};
			};

			networking.firewall = {
				enable = true;
				allowedTCPPorts = [
					80
					443
				];
				allowedUDPPorts = [ 51820 ];
			};

			security.acme.acceptTerms = true;
			# security.acme.useRoot = true;
			security.acme.defaults.email = "boss@tehbox.org";
			# security.acme.certs = {
			#     "tehbox.org" =
			#       {
			#           webroot = "/var/lib/acme/acme-challenge/";
			#           email = "boss@tehbox.org";
			#           extraDomainNames = (map (sub: sub + ".tehbox.org" ) [ "www" "git" ]);
			#           #dnsProvider = "linode";
			#           # dnsResolver = "92.123.94.2";
			#           # dnsPropagationCheck = false;
			#           #environmentFile = environmentFile;
			#       };
			# };
			users.groups.acme.members = [ "nginx" ];

			# Wireguard
			networking = {
				nat = {
					enable = true;
					externalInterface = "eth0";
					internalInterfaces = [ "wg0" ];
				};

				wireguard.interfaces.wg0 = {
					ips = [ "10.100.0.1/24" ];
					listenPort = 51820;

					postSetup = ''
            ${pkgs.iptables}/bin/iptables -t nat -A POSTROUTING -s 10.100.0.0/24 -o eth0 -j MASQUERADE
          '';
					postShutdown = ''
            ${pkgs.iptables}/bin/iptables -t nat -D POSTROUTING -s 10.100.0.0/24 -o eth0 -j MASQUERADE
          '';

					privateKeyFile = config.sops.secrets."wg/nixnode/priv".path;

					peers = [
						{
							name = "nixy";
							publicKey = "FMkFU9k+YeCvj48+WDVglySgoncbITqkS//o2e+TClY=";
							allowedIPs = [ "10.100.0.2/32" ];
						}
					];
				};
			};

			services.nginx = {
				enable = true;
				# Log the vhost at the start of each line ("vcombined") so goaccess
				# can split traffic by subdomain
				commonHttpConfig = ''
          log_format vcombined '$host:$server_port $remote_addr - $remote_user [$time_local] '
                               '"$request" $status $body_bytes_sent '
                               '"$http_referer" "$http_user_agent"';
          access_log /var/log/nginx/access.log vcombined;
        '';
				# virtualHosts.${config.mailserver.fqdn}.enableACME = true;
				virtualHosts = {
					"tehbox.org" = {
						root = "${inputs.self.packages.x86_64-linux.teh-website}/srv/www";
						serverAliases = [ "www.tehbox.org" ];
						enableACME = true;
						forceSSL = true;
					};
					"files.tehbox.org" = {
						root = "/srv/files";
						enableACME = true;
						forceSSL = true;
					};
					# "stk.lug.ac" = {
					#     root = "${inputs.self.packages.x86_64-linux.stk-installers}/srv/www";
					#     enableACME = true;
					#     forceSSL = true;
					#     locations."/".extraConfig = "autoindex on;\n";
					# };
					"dashboard.tehbox.org" = {
						root = "/var/lib/goaccess/html";
						basicAuthFile = config.sops.secrets."nginx/dashboard-htpasswd".path;
						enableACME = true;
						forceSSL = true;
					};
					"_" = {
						globalRedirect = "tehbox.org";
					};
				};
			};

			# Web traffic dashboard, rebuilt from the nginx access log every 10 minutes.
			# --persist/--restore keep the totals in /var/lib/goaccess/db across log rotations.
			systemd.services.goaccess-report = {
				description = "Build goaccess report for dashboard.tehbox.org";
				serviceConfig = {
					Type = "oneshot";
					User = "nginx";
					Group = "nginx";
					StateDirectory = [
						"goaccess"
						"goaccess/db"
						"goaccess/html"
					];
				};
				script = ''
          ${pkgs.goaccess}/bin/goaccess /var/log/nginx/access.log \
            --log-format=VCOMBINED \
            --num-tests=0 \
            --no-query-string \
            --persist --restore --db-path=/var/lib/goaccess/db \
            --html-report-title="tehbox.org traffic" \
            -o /var/lib/goaccess/html/index.html
        '';
			};
			systemd.timers.goaccess-report = {
				wantedBy = [ "timers.target" ];
				timerConfig = {
					OnCalendar = "*:0/10";
					Persistent = true;
				};
			};

			teh-nix.services.cgit = {
				enable = true;
				authorizedKeys = config.users.users.boss.openssh.authorizedKeys.keys;
				authorizedUsers = [ "boss" ];
				domain = "git.tehbox.org";
				enableACME = true;
				# useACMEHost = "tehbox.org";
				forceSSL = true;
				# onlySSL = true;
			};

			services.neodrive-website = {
				enable = true;
				domain = "neodrive.tehbox.org";
			};

			services.znc = {
				enable = true;
				mutable = true;
				useLegacyConfig = false;
				openFirewall = true;
				config = {
					SSLCertFile = "/var/lib/acme/tehbox.org/full.pem";
					LoadModule = [ "webadmin" ];
					User.boss = {
						Admin = true;
						Pass.password = {
							Method = "sha256";
							Hash = "401e8fed9a3ab1f93047b7465fd7cc6b0ca5aaed6b1c0482f0f4331ebdca8647";
							Salt = "*F_-,pqOdiJi;p)JoMnm";
						};
					};
					User.komodo = {
						Admin = false;
						Pass.password = {
							Method = "sha256";
							Hash = "2c624debe3e2672383346230b6acad82192e40df05666481f792a9dd97d935cc";
							Salt = "q9At0+KZvmofZil(3us1";
						};
					};
				};
			};

			services.openssh = {
				enable = true;
				settings.PermitRootLogin = "no";
				settings.PasswordAuthentication = false;
			};

			services.superTuxKarts = {
				enable = true;
				port = 2759;
				package = pkgs.superTuxKart;
				serverOptions = {
					server-name = "LUG STK server";
					server-mode = 3;
					server-difficulty = 3;
					server-max-players = 16;
					track-voting = false;
					voting-timeout = 15;
					private-server-password = "lug@uoa";
					motd = "Server for LUG@UoA\nChampionship coming soon!";
					live-spectate = true;
					server-configurable = true;
				};
			};

			mailserver = {
				enable = true;
				stateVersion = 3;
				fqdn = "tehbox.org";
				domains = [ "tehbox.org" ];

				x509.useACMEHost = config.mailserver.fqdn;

				loginAccounts = {
					"boss@tehbox.org" = {
						hashedPasswordFile = config.sops.secrets."mail/boss".path;
						aliases = [ "postmaster@tehbox.org" ];
					};
				};

				# certificateScheme = "acme";
			};

			users.users.boss = {
				isNormalUser = true;
				extraGroups = [
					"wheel"
					"networkmanager"
				]; # Enable ‘sudo’ for the user.
				home = "/home/boss";
				openssh.authorizedKeys.keys = [
					"ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIJOukEKExoF6vr3vciQN8pBdd4FtZtRzqIGFJrUvllOY boss@nixy"
				];
			};
			users.groups.files.members = [
				"boss"
				"nginx"
			];
			users.groups.nginx.members = [
				"nginx"
				"znc"
			];

			environment.systemPackages = with pkgs; [
				vim
				emacs
				inetutils
				mtr
				sysstat
				git
				goaccess
				inputs.self.packages.x86_64-linux.teh-website
				# inputs.self.packages.x86_64-linux.stk-installers
			];

			# Open ports in the firewall.
			# networking.firewall.allowedTCPPorts = [ ... ];
			# networking.firewall.allowedUDPPorts = [ ... ];
			# Or disable the firewall altogether.
			# networking.firewall.enable = false;

			networking.usePredictableInterfaceNames = false;
			networking.useDHCP = false;
			networking.interfaces.eth0.useDHCP = true;

			# Copy the NixOS configuration file and link it from the resulting system
			# (/run/current-system/configuration.nix). This is useful in case you
			# accidentally delete configuration.nix.
			# system.copySystemConfiguration = true;

			# This option defines the first version of NixOS you have installed on this particular machine,
			# and is used to maintain compatibility with application data (e.g. databases) created on older NixOS versions.
			#
			# Most users should NEVER change this value after the initial install, for any reason,
			# even if you've upgraded your system to a new NixOS release.
			#
			# This value does NOT affect the Nixpkgs version your packages and OS are pulled from,
			# so changing it will NOT upgrade your system - see https://nixos.org/manual/nixos/stable/#sec-upgrading for how
			# to actually do that.
			#
			# This value being lower than the current NixOS release does NOT mean your system is
			# out of date, out of support, or vulnerable.
			#
			# Do NOT change this value unless you have manually inspected all the changes it would make to your configuration,
			# and migrated your data accordingly.
			#
			# For more information, see `man configuration.nix` or https://nixos.org/manual/nixos/stable/options#opt-system.stateVersion .
			system.stateVersion = "25.05"; # Did you read the comment?

		};
}
