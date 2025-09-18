{ pkgs, lib, config, ... }:
let
    cfg = config.teh-nix.services.cgit;
    cgitrc = pkgs.writeText "cgitrc" ''
css=/static/cgit.css
logo=/static/cgit.png
favicon=/static/favicon.ico
repository-sort=age

root-title=${cfg.title}
root-desc=${cfg.description}

enable-blame=1
enable-commit-graph=1
enable-log-filecount=1
enable-log-linecount=1
enable-index-links=1

snapshots=tar.gz zip
enable-http-clone=1
clone-prefix=https://${cfg.domain}

readme=:README
readme=:readme
readme=:readme.txt
readme=:README.txt
readme=:readme.md
readme=:README.md

${cfg.extraConfig}

about-filter=${cfg.package}/lib/cgit/filters/about-formatting.sh
source-filter=${cfg.package}/lib/cgit/filters/syntax-highlighting.py

enable-git-config=1
scan-path=${cfg.directory}
'';
in
{
    options.teh-nix.services.cgit = with lib;{
        enable = mkEnableOption "Enable cgit";
        user = mkOption {
            type = types.str;
            default = "cgit";
            description = "Username for the user that will run cgit";
        };
        authorizedKeys = lib.mkOption {
            type = types.listOf types.str;
            default = [ ];
            description = "List of ssh keys for the cgit user (cgit user should own all repos)";
        };
        authorizedUsers = lib.mkOption {
            type = types.listOf types.str;
            default = [ ];
            description = "List of users that should have access to the cgit directory";
        };
        directory = mkOption {
            type = types.str;
            default = "/srv/cgit/repos";
            description = "Directory for cgit (cgit user's home directory";
        };
        description = mkOption {
            type = types.str;
            default = "Cgit instance hosted with nixos";
            description = "Description of the cgit website";
        };
        title = mkOption {
            type = types.str;
            default = "Cgit + Nix";
            description = "Title of the cgit website";
        };
        domain = mkOption {
            type = types.str;
            default = "git.example.com";
            description = "Domain to host it on";
        };
        package = mkPackageOption pkgs "cgit" { };
        extraConfig = mkOption {
            type = types.str;
            default = "";
            description = "Extra config to be appended to cgitrc";
        };
    };

    config = lib.mkIf cfg.enable {
        environment.systemPackages = [ pkgs.git cfg.package ];
        users = {
            groups.${cfg.user} = {
                members = cfg.authorizedUsers;
            };
            users.${cfg.user} = {
                createHome = true;
                homeMode = "770";
                home = cfg.directory;
                isSystemUser = true;
                shell = "${pkgs.git}/bin/git-shell";
                openssh.authorizedKeys.keys = cfg.authorizedKeys;
                group = cfg.user;
            };
        };


        services.fcgiwrap.instances.cgit = {
            socket = {
                user = cfg.user;
                group = "nginx";
                type = "unix";
                mode = "0660";
            };
            process = {
                user = cfg.user;
                group = cfg.user;
            };
        };
        
        services.nginx.enable = true;
        services.nginx.virtualHosts.${cfg.domain} = {
            locations."~* ^/static/(.+.(ico|css|png))$" = {
                extraConfig = ''
alias ${cfg.package}/cgit/$1;
'';
            };
            locations."/" = {
                extraConfig = ''
include ${pkgs.nginx}/conf/fastcgi_params;
fastcgi_param CGIT_CONFIG ${cgitrc};
fastcgi_param SCRIPT_FILENAME ${cfg.package}/cgit/cgit.cgi;
fastcgi_split_path_info ^(/?)(.+)$;
fastcgi_param PATH_INFO $fastcgi_path_info;
fastcgi_param QUERY_STRING $args;
fastcgi_param HTTP_HOST $server_name;
fastcgi_pass unix:${config.services.fcgiwrap.instances.cgit.socket.address};
        '';
            };
        };
    };
}
