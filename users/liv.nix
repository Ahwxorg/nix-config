{ lib, config, pkgs,  ... }:

{
  imports =
  [
    # nixvim.homeManagerModules.nixvim
  ];

# Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.liv = {
    isNormalUser = true;
    initialPassword = "123456";
    description = "liv's user account";
    shell = pkgs.zsh;
    extraGroups = [ "networkmanager" "wheel" ];
    packages = with pkgs; [
      neovim
      tmux
      lazygit
      neofetch
      eza
      htop
      ripgrep
      gcc
    ];
    openssh.authorizedKeys.keys = [ "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQC76g1k1112/yFNgTVbza3KV9usRKldaPx1kmvwiXdxbe3w62VrMGr0gkttIVv9q2UkXxjFvYDRLQYhIpOuPMMdx0ignXAaMv5Xk6tliUd0MG1TIYlbHGWMz4aKhDyt2813Qeu4H2nxhMCQ9cKApmKFfjOp9FYal5TQFDezYdl3KSqFuGtHsyEFxTEsFsJRopMpEBGRAeesTW0awknx6R2/X0rvEwcQBW89UHwwvqHHs06Rgobemev+3yZdeaigpwUuFmrjebGGCZxGtMALfNbQDXORH2nkIYg8cvxu5xLc3gkD/+HIdg32uwT6L6Inq8XwdJS5fidXjK/R92+DEgQQ0NSQ40nyNWxX3FEolWtQ69WOWcVuGNhdum4ifn4xVWrI0vK8tmBgNJHCoygIv3OcsgVKOQSUz0wM0QhwXMb77FbaQOWmf0HyN3CU4ZDWDFGCkRDFUnv4f2/pKN1rnV1mNCoyBCsuUwpqdrPAc64Kz1A0XWWiBuT8qkRT+//88HM=" ];
  };
  
  home-manager.users.liv = {
    programs.git = {
      enable = true;
      userName  = "Ahwx";
      userEmail = "ahwx@ahwx.org";
    };

    programs.zsh = {
      enable = true;
      autocd = true;
      enableAutosuggestions = true;
      enableCompletion = true;
  
      localVariables = {
        # Looks like this: '~/some/path > '
        PS1 = "%F{magenta}%~%f > ";
        # Gets pushed to the home directory otherwise
        LESSHISTFILE = "/dev/null";
        # Make Vi mode transitions faster (in hundredths of a second)
        # KEYTIMEOUT = 1;
      };

      shellAliases = {
        ls = "eza -lh";
        la = "eza -A";
        ll = "eza -l";
        lla = "eza -lA";
        # :q = "exit";
        ezit = "exit";
        notes = "nvim ~/Documents/todo.md";
        todo = "nvim ~/Documents/todo.md";
        irc = "ssh irc";
        tmuxconf = "nvim ~/.config/tmux/tmux.conf";
        nvimconf = "cd ~/.config/nvim && nvim";
        termconf = "nvim ~/.config/alacritty/alacritty.yml";
        reboot-to-macos = "echo 1 | doas asahi-bless 1>/dev/null && doas reboot";
        wc = "wl-copy";
        zshrc = "nvim ~/.zshrc";
        yt-dlp-audio = "yt-dlp -f 'ba' -x --audio-format mp3";
        emerge = "doas emerge";
        zshconf = "nvim ~/.zshrc";
        open = "xdg-open";
      };

      plugins = with pkgs; [
      {
        name = "zsh-syntax-highlighting";
        src = fetchFromGitHub {
          owner = "zsh-users";
          repo = "zsh-syntax-highlighting";
          rev = "0.6.0";
          sha256 = "0zmq66dzasmr5pwribyh4kbkk23jxbpdw4rjxx0i7dx8jjp2lzl4";
        };
        file = "zsh-syntax-highlighting.zsh";
      }
      {
        name = "zsh-autopair";
        src = fetchFromGitHub {
          owner = "hlissner";
          repo = "zsh-autopair";
          rev = "34a8bca0c18fcf3ab1561caef9790abffc1d3d49";
          sha256 = "1h0vm2dgrmb8i2pvsgis3lshc5b0ad846836m62y8h3rdb3zmpy1";
        };
        file = "autopair.zsh";
      }
      ];
    };

    programs.fzf = {
      enable = true;
      enableZshIntegration = true;
    };
  };

  programs.zsh.enable = true;
}
