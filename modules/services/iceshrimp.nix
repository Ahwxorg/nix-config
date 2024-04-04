{ lib, config, pkgs,  ... }:
{
  services.iceshrimp = {
    enable = true; # Actually enable the module
    url = "https://quack.social"; # The domain your Iceshrimp UI will be served on.
  };
}
