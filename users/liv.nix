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
    openssh.authorizedKeys.keys = [ "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIGXi00z/rxVrWLKgYr+tWIsbHsSQO75hUMSTThNm5wUw liv@lila" ];
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
	nvim = "nix run /home/liv/nixvim-config --";
	doas = "sudo";
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
