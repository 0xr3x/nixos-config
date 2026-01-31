{ config, pkgs, inputs, ... }:

{
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
      rebuild = "sudo nixos-rebuild switch";
      update = "sudo nixos-rebuild switch --upgrade";
      cleanup = "sudo nix-collect-garbage -d";
      bat-check = "acpi -b";
      bright = "brightnessctl";
    };
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
