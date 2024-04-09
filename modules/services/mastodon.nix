{ lib, config, pkgs,  ... }:
{
  security.acme = {
    acceptTerms = true;
    defaults.email = "letsencrypt@ahwx.org";
  };
  services.mastodon = {
    enable = true;
    localDomain = "social.quack.social";
    configureNginx = true;
    smtp.fromAddress = "noreply@quack.social";
    extraConfig.SINGLE_USER_MODE = "false";
    extraConfig.DISABLE_AUTOMATIC_SWITCHING_TO_APPROVED_REGISTRATIONS = "false";
    streamingProcesses = 3;
  };
  #networking.firewall.allowedTCPPorts = [ 80 443 ];
}
