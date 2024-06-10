{ config, ... }:
{
  virtualisation.docker.enable = true;
  users.users.liv.extraGroups = [ "docker" ];

  virtualisation.oci-containers = {
    containers = {
      quack-social-frontend = {
        image = "ghcr.io/quack-social/quack.social";
        autoStart = true;
      };
    };
  };
}
