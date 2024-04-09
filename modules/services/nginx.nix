{ lib, config, pkgs,  ... }:
{
  services.nginx.enable = true;
  services.nginx.virtualHosts."quack.social" = {
      addSSL = true;
      enableACME = true;
      root = "/var/www/quack.social/dist";
  };
  security.acme = {
    acceptTerms = true;
    defaults.email = "letsencrypt@ahwx.org";
  };
}
