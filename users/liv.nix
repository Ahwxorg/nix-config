{ lib, config, pkgs,  ... }:

{
# Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.liv = {
    isNormalUser = true;
    initialPassword = "123456";
    description = "liv's user account";
    shell = pkgs.zsh;
    extraGroups = [ "networkmanager" "wheel" ];
    packages = with pkgs; [
      firefox
      neovim
      tmux
      wget
    ];
    openssh.authorizedKeys.keys = [ "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQC76g1k1112/yFNgTVbza3KV9usRKldaPx1kmvwiXdxbe3w62VrMGr0gkttIVv9q2UkXxjFvYDRLQYhIpOuPMMdx0ignXAaMv5Xk6tliUd0MG1TIYlbHGWMz4aKhDyt2813Qeu4H2nxhMCQ9cKApmKFfjOp9FYal5TQFDezYdl3KSqFuGtHsyEFxTEsFsJRopMpEBGRAeesTW0awknx6R2/X0rvEwcQBW89UHwwvqHHs06Rgobemev+3yZdeaigpwUuFmrjebGGCZxGtMALfNbQDXORH2nkIYg8cvxu5xLc3gkD/+HIdg32uwT6L6Inq8XwdJS5fidXjK/R92+DEgQQ0NSQ40nyNWxX3FEolWtQ69WOWcVuGNhdum4ifn4xVWrI0vK8tmBgNJHCoygIv3OcsgVKOQSUz0wM0QhwXMb77FbaQOWmf0HyN3CU4ZDWDFGCkRDFUnv4f2/pKN1rnV1mNCoyBCsuUwpqdrPAc64Kz1A0XWWiBuT8qkRT+//88HM=" ];
  };
  
  programs.zsh = {
    enable = true;
    autosuggestions.enable = true;
    enableCompletion = true;
  };

  programs.git = {
    enable = true;
    userName  = "Ahwx";
    userEmail = "ahwx@ahwx.org";
  };
}