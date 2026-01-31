{ config, pkgs, inputs, ... }:

{
  imports = [
    ./modules/home/terminal.nix
  ];

  programs.home-manager.enable = true;

  home.username = "rex";
  home.homeDirectory = "/home/rex";
  home.stateVersion = "25.11";
  home.sessionPath = [
    "$HOME/.local/bin"
  ];

  # Bash configuration
  programs.bash = {
    enable = true;
    shellAliases = {
      ll = "ls -lah";
      ls = "eza";
      cat = "bat";
      grep = "rg";
      find = "fd";
      top = "btop";
      rebuild = "nh os switch";
      update = "nh os switch --update";
      cleanup = "nh clean all --keep 5";
      bat-check = "acpi -b";
      bright = "brightnessctl";
      cd = "z";  # use zoxide
    };
  };

  # Better shell prompt
  programs.starship = {
    enable = true;
    enableBashIntegration = true;
    settings = {
      add_newline = false;
      character = {
        success_symbol = "[➜](bold green)";
        error_symbol = "[➜](bold red)";
      };
      directory = {
        truncation_length = 3;
        truncate_to_repo = true;
      };
    };
  };

  programs.fzf = {
    enable = true;
    enableBashIntegration = true;
    defaultCommand = "fd --type f";  # use fd instead of find
  };

  # Auto-load project environments
  programs.direnv = {
    enable = true;
    enableBashIntegration = true;
    nix-direnv.enable = true;
  };

  # Smart directory jumping
  programs.zoxide = {
    enable = true;
    enableBashIntegration = true;
  };

  # Better manpages
  programs.man = {
    enable = true;
    generateCaches = true;
  };

  # autostart 1password
  xdg.configFile."autostart/1password.desktop".source = "${pkgs._1password-gui}/share/applications/1password.desktop";

  home.packages = (with pkgs; [
    # Communication
    discord
    slack
    telegram-desktop

    # Media
    spotube

    # Browsers
    brave

    # Hardware wallets
    trezor-suite
    trezorctl

    # KDE apps
    kdePackages.kate

    # Development tools
    code-cursor-fhs
    nodejs_22
    pnpm
    uv
    foundry
    claude-code

    # Office
    wpsoffice

    # Battery monitoring tools
    brightnessctl
    acpi
    powertop

    # System monitoring
    btop

    # CLI utilities
    ripgrep
    fd
    eza
    bat
    jq      # JSON processor
    yq-go   # YAML processor
    httpie  # better curl for APIs
    nh      # nix-helper: better nixos-rebuild

    ]) ++ [
        inputs.zen-browser.packages.${pkgs.system}.default
    ];

  # Git configuration
  programs.git = {
    enable = true;

    settings = {
      user = {
        name = "0xr3x";
        email = "133902786+0xr3x@users.noreply.github.com";
      };

      gpg = {
        format = "ssh";
        ssh.program = "${pkgs._1password-gui}/bin/op-ssh-sign";
      };

      commit = {
        gpgsign = true;
      };
    };

    signing = {
      key = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIKuxYP9adFjxLE3vCvSpuxtL/1uEz/f14/CL0ymqMxCW";
      signByDefault = true;
    };
  };
}
