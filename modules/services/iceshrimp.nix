{
  config,
  lib,
  pkgs,
  modulesPath,
  ...
}: let
  inherit (lib) mkOption mkEnableOption types mdDoc;
  cfg = config.services.iceshrimp;
  settingsFormat = pkgs.formats.yaml {};
  configFile = settingsFormat.generate "default.yml" cfg.settings;
  pgBin = "${pkgs.postgresql}/bin/psql";
in {
  options.services.iceshrimp = {
    enable = mkEnableOption "Iceshrimp ActivityPub server";

    package = mkOption {
      type = types.package;
      default = pkgs.callPackage ./package.nix {};
      description = "The package to use for the Iceshrimp service.";
    };

    secretConfig = mkOption {
      type = with types; either str path;
      example = /path/to/secret/config.yml;
      default = "";
      description = ''
        The secret config. Use this to configure things like the Postgres and Redis passwords, if needed.
        Can also include any other secret options that you don't want publically available.
      '';
    };

    envFile = mkOption {
      type = types.nullOr types.path;
      example = /path/to/secret.env;
      default = null;
      description = ''
        The secret environment file to load into the server services.
      '';
    };

    # User and group for Iceshrimp to run under.
    user = mkOption {
      type = types.nonEmptyStr;
      example = "iceshrimp-user";
      default = "iceshrimp";
      description = "User that the Iceshrimp service runs under.";
    };
    group = mkOption {
      type = types.nonEmptyStr;
      example = "iceshrimp-user";
      default = "iceshrimp";
      description = "Group that the Iceshrimp service runs under.";
    };

    # Whether to create a Postgres DB locally. Does not set a password unless the dbPasswordFile option is set.
    createDb = mkOption {
      type = types.bool;
      default = false;
      description = "Whether to create a local Postgres database for Iceshrimp, also creates the iceshrimp user and database inside Postgres.";
    };

    # The postgres password file, should contain the password and nothing else.
    dbPasswordFile = mkOption {
      type = types.nullOr types.path;
      example = /path/to/password/file;
      default = null;
      description = ''
        A file containing the password for the user that Iceshrimp accesses the database as. Will not be used if unset.
        If using this, ensure that db.pass is set in your `secretConfig` file.
      '';
    };

    configureNginx = mkOption {
      description = "Nginx configuration for Iceshrimp, using reasonable defaults mirroring [example Nginx config](https://iceshrimp.dev/iceshrimp/iceshrimp/src/branch/dev/docs/examples/iceshrimp.nginx.conf).";
      type = with types; (submodule { options = {
        enable = mkEnableOption "Iceshrimp Nginx virtual host with sane defaults.";
        config = mkOption {
          type = submodule (import (modulesPath + "/services/web-servers/nginx/vhost-options.nix") { inherit config lib; });
          description = "Customize an nginx virtual host which already has sensible defaults for Iceshrimp.";
          default = {};
      };};});
    };

    stateDir = mkOption {
      type = types.path;
      default = "/var/lib/iceshrimp";
      description = "Where iceshrimp should store all of its state data.";
    };
    mediaDir = mkOption {
      type = types.path;
      example = /path/to/iceshrimp/media;
      default = "${cfg.stateDir}/files";
      description = "Where iceshrimp stores its files, defaults to /files in the stateDir.";
    };
    settings = mkOption {
      description = ''
        The Iceshrimp settings to use, defaults taken from the default config.
        Note that you are only required to set the `url` setting, all other settings have defaults. This is to prevent starting an instance with no URL, which doesn't work.
        See [The example config](https://iceshrimp.dev/iceshrimp/iceshrimp/src/branch/dev/.config/example.yml) for all available keys.
      '';
      type = types.submodule {
        freeformType = settingsFormat.type;
        options = {
          url = mkOption {
            type = types.nullOr (types.addCheck types.nonEmptyStr (s: (lib.hasPrefix "https://" s) || (lib.hasPrefix "http://" s)));
            example = "https://example.com";
            default = null;
            description = ''
              The publically accessible URL of the Iceshrimp instance, beginning with "https://" (recommended) or "http://".
              CANNOT BE CHANGED AFTER INSTALLATION!!
            '';
          };
          accountDomain = mkOption {
            type = types.nullOr types.str;
            example = "example.social";
            default = null;
            description = "OPTIONAL - Domain used for account handles, if you want the frontend at a subdomain but for account handles to be on a root domain, i.e. having the frontend at iceshrimp.example.social but the accounts being of the form @account@example.social.";
          };
          port = mkOption {
            type = types.port;
            example = 3001;
            default = 3000;
            description = "The listening port for the Iceshrimp service.";
          };
          db = {
            host = mkOption {
              type = types.str;
              example = "iceshrimp-db-host";
              default = "localhost";
              description = "The host to connect to for Postgres. Leave unset if createDb is enabled, this will be auto-configured.";
            };
            port = mkOption {
              type = types.port;
              example = 5433;
              default = 5432;
              description = "The port that Postgres is running on. Leave unset if using createDb.";
            };
            ssl = mkOption {
              type = types.bool;
              example = true;
              default = false;
              description = "Whether to use SSL to connect to Postgres. Leave unset if using createDb.";
            };
            db = mkOption {
              type = types.str;
              example = "iceshrimp-db-name";
              default = "iceshrimp";
              description = "The database that iceshrimp will use inside Postgres. Leave unset if using createDb.";
            };
            user = mkOption {
              type = types.str;
              example = "iceshrimp-db-user";
              default = "iceshrimp";
              description = "The database user for Iceshrimp to use.";
            };
          };
          redis = {
            host = mkOption {
              type = types.str;
              example = "iceshrimp-redis-host";
              default = "localhost";
              description = "The Redis server that Iceshrimp will connect to.";
            };
            port = mkOption {
              type = types.port;
              example = 6378;
              default = 6379;
              description = "The port that Iceshrimp will connect to Redis on.";
            };
          };
          cuid = {
            length = mkOption {
              type = types.ints.between 16 24;
              example = 18;
              default = 16;
              description = "The length of the cuid to generate. The default should be fine, but if you are running a large or distributed server, consider increasing it.";
            };
            fingerprint = mkOption {
              type = types.nullOr types.nonEmptyStr;
              example = "my-fingerprint";
              default = null;
              description = ''
                Set this to a unique string across workers(such as the machine's hostname)
                ONLY if your workers are running in multiple hosts.
              '';
            };
          };
          maxNoteLength = mkOption {
            type = types.ints.between 1 100000;
            example = 5000;
            default = 3000;
            description = "The maximum note length to allow users to send.";
          };
          maxCaptionLength = mkOption {
            type = types.ints.between 1 8192;
            example = 2000;
            default = 1500;
            description = "The maximum caption length to allow users to add to an image.";
          };
          reservedUsernames = mkOption {
            type = types.listOf types.nonEmptyStr;
            example = ["some" "example" "usernames"];
            default = ["root" "admin" "administrator" "me" "system"];
            description = "Usernames that only the administrator is allowed to register with.";
          };
          disableHsts = mkOption {
            type = types.bool;
            example = false;
            default = true;
            description = "Whether to disable HSTS for the Iceshrimp server.";
          };
          clusterLimit = mkOption {
            type = types.int;
            example = 4;
            default = 1;
            description = "How many worker processes to run.";
          };
          onlyQueueProcessor = mkOption {
            type = types.ints.between 0 1;
            example = 1;
            default = 0;
            description = "Whether to run in worker-only mode.";
          };
          deliverJobConcurrency = mkOption {
            type = types.int;
            example = 64;
            default = 128;
            description = "The max deliver jobs to run on a worker.";
          };
          inboxJobPerSec = mkOption {
            type = types.int;
            example = 32;
            default = 16;
            description = "The max inbox jobs to run on a worker.";
          };
          deliverJobMaxAttempts = mkOption {
            type = types.int;
            example = 10;
            default = 12;
            description = "The maximum number of times to attempt sending a deliver job before aborting.";
          };
          inboxJobMaxAttempts = mkOption {
            type = types.int;
            example = 6;
            default = 8;
            description = "The maximum number of times to attempt sending an inbox job before aborting.";
          };
          outgoingAddressFamily = mkOption {
            type = types.enum ["ipv4" "ipv6" "dual"];
            example = "dual";
            default = "ipv4";
            description = "The IP address family to use for outgoing requests.";
          };
          syslog = {
            host = mkOption {
              type = types.nullOr types.nonEmptyStr;
              example = "localhost";
              default = null;
              description = "The host that should recieve syslog logs from Iceshrimp.";
            };
            port = mkOption {
              type = types.nullOr types.port;
              example = 514;
              default = null;
              description = "The port that the syslog server is listening on.";
            };
          };
          proxy = mkOption {
            type = types.nullOr types.nonEmptyStr;
            example = "http://127.0.0.1:3128";
            default = null;
            description = "The HTTP/HTTPS proxy to use.";
          };
          proxyBypassHosts = mkOption {
            type = types.listOf types.nonEmptyStr;
            example = ["web.kaiteki.app" "127.0.0.1"];
            default = [];
            description = "Hosts that should not be connected to with the proxy.";
          };
          proxySmtp = mkOption {
            type = types.nullOr types.nonEmptyStr;
            example = "http://127.0.0.1:3128";
            default = null;
            description = "The proxy to use for SMTP. Can be an http, socks4, or socks5 proxy.";
          };
          mediaProxy = mkOption {
            type = types.nullOr types.nonEmptyStr;
            example = "https://example.com/proxy";
            default = null;
            description = "The proxy to use to send media to the client.";
          };
          proxyRemoteFiles = mkOption {
            type = types.bool;
            example = true;
            default = false;
            description = "Whether to proxy remote files.";
          };
          mediaCleanup = {
            cron = mkOption {
              type = types.bool;
              example = true;
              default = false;
            };
            maxAgeDays = mkOption {
              type = types.int;
              example = 30;
              default = 0;
              description = "The number of days to keep media for";
            };
            cleanAvatars = mkOption {
              type = types.bool;
              example = true;
              default = false;
              description = "Whether to clean avatars on a timer with other media.";
            };
            cleanHeaders = mkOption {
              type = types.bool;
              example = true;
              default = false;
              description = "Whether to clean headers on a timer with other media.";
            };
          };
          images = {
            info = mkOption {
              type = types.str;
              example = "/twemoji/1f440.svg";
              default = "/twemoji/1f440.svg";
              description = "Path to the image to use for the info icon.";
            };
            notFound = mkOption {
              type = types.str;
              example = "/twemoji/2049.svg";
              default = "/twemoji/2049.svg";
              description = "Path to the image to use for the notFound icon.";
            };
            error = mkOption {
              type = types.str;
              example = "/twemoji/1f480.svg";
              default = "/twemoji/1f480.svg";
              description = "Path to the image to use for the error icon.";
            };
          };
          searchEngine = mkOption {
            type = types.str;
            example = "https://search.brave.com/search?q=";
            default = "https://duckduckgo.com/?q=";
            description = "The search engine base string to use for the MFM search box.";
          };
          allowedPrivateNetworks = mkOption {
            type = types.listOf types.nonEmptyStr;
            example = ["127.0.0.1/32"];
            default = ["127.0.0.1/32"];
            description = "The networks to classify as private when connecting to the server.";
          };
          twa = {
            nameSpace = mkOption {
              type = types.nullOr types.nonEmptyStr;
              example = "android_app";
              default = null;
              description = "The TWA namespace to allow.";
            };
            packageName = mkOption {
              type = types.nullOr types.nonEmptyStr;
              example = "tld.domain.twa";
              default = null;
              description = "The name of the android app package that can use this TWA.";
            };
            sha256CertFingerprints = mkOption {
              type = types.nullOr (types.listOf types.nonEmptyStr);
              example = ["AB:CD:EF"];
              default = null;
              description = "The SHA256 certificate fingerprint(s) of the app package abouve";
            };
          };
          maxFileSize = mkOption {
            type = types.int;
            example = 100000;
            default = 262144000;
            description = "The max upload file size. Defaults to 250 MB.";
          };
          htmlCache = {
            ttl = mkOption {
              type = types.str;
              example = "6h";
              default = "1h";
              description = "How long entries should be kept in the HTML cache.";
            };
            prewarm = mkOption {
              type = types.bool;
              example = true;
              default = false;
              description = ''
                Prerender every incoming user/note create/update event so that the cache is always "warm."
                Trades background CPU load for lower request response times.
              '';
            };
            dbFallback = mkOption {
              type = types.bool;
              example = true;
              default = false;
              description = ''
                Store expired HTML data in Postgres, so it can be fetched from the database rather than re-rendered.
                This is more expensive than fetching from Redis, but cheaper than rendering from scratch.
                Does increase DB storage space used.
              '';
            };
          };
          wordMuteCache = {
            ttl = mkOption {
              type = types.str;
              example = "12h";
              default = "24h";
              description = ''
                Duration hard muted notes are stored in Redis for.
                Trades higher memory consumption for lower CPU usage on repeated requests within the value set.
              '';
            };
          };
        };
      };
    };
  };
  config = lib.mkIf cfg.enable {
    assertions = [{
      assertion = cfg.settings.url != null;
      message = "Please set `iceshrimp.settings.url`, the service will not work without it!";
    }];

    # Create our user and group
    users.users.${cfg.user} = {
      description = "Iceshrimp ActivityPub Server User";
      group = cfg.group;
      home = cfg.stateDir;
      isSystemUser = true;
      createHome = true;
    };
    users.groups.${cfg.group} = {};

    # Main Iceshrimp Service
    systemd.services.iceshrimp = lib.mkIf cfg.enable {
      description = "Iceshrimp ActivityPub Server";
      wantedBy = [ "multi-user.target" ];
      after = [
        "iceshrimp-init.service"
        "redis.service" 
        "network-online.service"
      ] ++ (lib.optionals cfg.createDb [ "postgresql.service" "iceshrimp-db-init.service" ]);
      
      environment = {
        NODE_ENV = "production";
        ICESHRIMP_CONFIG = configFile;
        ICESHRIMP_MEDIA_DIR = "${cfg.mediaDir}";
        ICESHRIMP_SECRETS = cfg.secretConfig;
      };

      serviceConfig = {
        Type = "simple";
        Restart = "on-failure";

        User = cfg.user;
        Group = cfg.group;

        # Set working directory properly so that yarn can find the files.
        WorkingDirectory = cfg.package;
        SyslogIdentifier = "iceshrimp";
        ExecStart = "${cfg.package}/yarn.js start";
        # Run migrations in a separate process before starting the service.
        ExecStartPre = "${cfg.package}/yarn.js migrate";

        # Hardening options
        ReadOnlyPaths = [ cfg.package configFile cfg.secretConfig ];
        ReadWritePaths = [ "${cfg.stateDir}/files" "${cfg.stateDir}/.cache" ];
        NoExecPaths = [ "${cfg.stateDir}/files" "${cfg.stateDir}/.cache" ];
        RestrictSUIDSGID = true;
        RestrictNamespaces = true;
        PrivateTmp = true;
        PrivateDevices = true;
        PrivateUsers = true;
        ProtectHostname = true;
        ProtectClock = true;
        ProtectKernelTunables = true;
        ProtectKernelModules = true;
        ProtectKernelLogs = true;
        ProtectControlGroups = true;
        ProtectSystem = "strict";
        ProtectHome = true;
        ProtectProc = "invisible";
        SystemCallArchitectures = "native";
        SystemCallFilter = "@system-service";
        SystemCallErrorNumber = "EPERM";
        LockPersonality=true;
        NoNewPrivileges=true;
      } // (lib.optionalAttrs (cfg.envFile != null) { EnvironmentFile = cfg.envFile; });
    };
    # If we create a database locally, ensure our database and user exist.
    services.postgresql = lib.mkIf cfg.createDb {
      enable = true;
      ensureUsers = [{
        name = cfg.settings.db.user;
        ensureClauses.createdb = true;
        ensureClauses.login = true;
      }];
    };
    # We will always default create a redis server, better to have it locally
    # Also it doesn't consume too much memory so there's very little downside.
    services.redis.servers.iceshrimp = {
      enable = true;
      port = cfg.settings.redis.port;
    };
    # Set up Nginx to use sane defaults.
    services.nginx = with lib; let
      hasSSL = hasPrefix "https" cfg.settings.url;
    in mkIf cfg.configureNginx.enable {
      enable = true;
      recommendedTlsSettings = mkDefault true;
      clientMaxBodySize = mkDefault "80m";
      proxyCachePath."iceshrimp" = mkDefault { enable = true; keysZoneSize = "16m"; inactive = "720m"; };
      virtualHosts.${removePrefix "http${optionalString hasSSL "s"}://" cfg.settings.url} = lib.recursiveUpdate {
        enableACME = hasSSL;
        forceSSL = hasSSL;
        http2 = true;
        listen = lib.concatMap (la: ([ { addr = la; port = 80; ssl = false; } ] ++ (optionals hasSSL [ { addr = la; port = 443; ssl = true; } ])) ([ "0.0.0.0" ] ++ (optionals config.networking.enableIPv6 [ "[::]" ])));
        locations."/" = {
          recommendedProxySettings = true;
          proxyPass = "http://127.0.0.1:"+(builtins.toString cfg.settings.port);
          proxyWebsockets = true;
          extraConfig = "proxy_cache cache;\nproxy_cache_lock on;\nproxy_cache_use_stale updating;\nadd_header X-Cache $upstream_cache_status;";
        };
      } cfg.configureNginx.config;
    };

    # Service that sets up the database if we create one locally.
    # Disabled if there is no local database creation.
    systemd.services.iceshrimp-init = {
      description = "Setup script for Iceshrimp";
      before = [ "iceshrimp.service" "iceshrimp-db-init.service" ];
      wantedBy = [ "multi-user.target" ];
      serviceConfig = {
        Type = "oneshot";
        User = cfg.user;
        Group = cfg.group;
      };
      script = ''
        mkdir -p ${cfg.mediaDir} ${cfg.stateDir}/.cache
      '';
    };
    systemd.services.iceshrimp-db-init = {
      enable = cfg.createDb;
      description = "Setup script for Iceshrimp's database";
      requires = [ "postgresql.service" ];
      after = [ "postgresql.service" "iceshrimp-init.service" ];
      before = [ "iceshrimp.service" ];
      wantedBy = [ "multi-user.target" ];
      serviceConfig = {
        Type = "oneshot";
        ReadOnlyPaths = lib.optionals (cfg.dbPasswordFile != null) [ cfg.dbPasswordFile ];
        ReadWritePaths = ["${cfg.stateDir}/.cache"];
        User = "postgres";
        Group = "postgres";
      };
      script = ''
        if ! ${pgBin} -d ${cfg.settings.db.db}; then
          ${pgBin} -U postgres postgres \
            -c "CREATE DATABASE ${cfg.settings.db.db} OWNER ${cfg.settings.db.user} ENCODING 'UTF8'"
        fi
        ${pgBin} -U postgres postgres \
          -c "GRANT ALL PRIVILEGES ON DATABASE ${cfg.settings.db.db} to ${cfg.settings.db.user};"
        ${
          lib.optionalString (cfg.dbPasswordFile != null) ''
            POSTGRES_PASSWORD="$(<"${cfg.dbPasswordFile}")"
            ${pgBin} -U postgres postgres \
              -c "ALTER USER ${cfg.settings.db.user} WITH ENCRYPTED PASSWORD '$POSTGRES_PASSWORD';"
          ''
        }
      '';
    };
  };
}
