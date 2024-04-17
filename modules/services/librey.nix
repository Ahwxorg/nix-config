{ config, vars, ... }:
{
  virtualisation.docker.enable = true;
  users.users.liv.extraGroups = [ "docker" ];

  virtualisation.oci-containers = {
    containers = {
      librey = {
        image = "ghcr.io/ahwxorg/librey:latest";
        autoStart = true;
        extraOptions = [
        ""
        ];
        environment = {
          TZ = vars.timeZone;
          PUID = "994";
          GUID = "993";
          CONFIG_GOOGLE_DOMAIN = "com";
          CONFIG_LANGUAGE = "en";
          CONFIG_NUMBER_OF_RESULTS = "10";
          CONFIG_INVIDIOUS_INSTANCE = "https://yt.ahwx.org";
          CONFIG_DISABLE_BITTORRENT_SEARCH = "false";
          CONFIG_HIDDEN_SERVICE_SEARCH = "false";
          CONFIG_INSTANCE_FALLBACK = "true";
          CONFIG_RATE_LIMIT_COOLDOWN = "25";
          CONFIG_CACHE_TIME = "20";
          CONFIG_DISABLE_API = "false";
          CONFIG_TEXT_SEARCH_ENGINE = "auto";
          CURLOPT_PROXY_ENABLED = "false";
          CURLOPT_PROXY = "192.0.2.53:8388";
          CURLOPT_PROXYTYPE = "CURLPROXY_HTTP";
          CURLOPT_USERAGENT = "Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:116.0) Gecko/20100101 Firefox/116.0";
          CURLOPT_FOLLOWLOCATION = "true";
        };
      };
    };
  };
}
