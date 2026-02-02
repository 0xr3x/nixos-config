{ config, pkgs, inputs, ... }:

{
  imports = [
    ./modules/home/terminal.nix
    ./modules/home/shell.nix
    ./modules/home/git.nix
  ];

  programs.home-manager.enable = true;

  home.username = "rex";
  home.homeDirectory = "/home/rex";
  home.stateVersion = "25.11";
  home.sessionPath = [
    "$HOME/.local/bin"
  ];

  home.sessionVariables = {
    NH_FLAKE = "/etc/nixos";
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
    gh          # GitHub CLI
    lazygit     # TUI for git
    docker-compose

    # Office
    wpsoffice

    # Media
    mpv         # Best video player
    flameshot   # Better screenshots

    # Torrents
    transmission_4-gtk

    # Battery monitoring tools
    brightnessctl
    acpi
    powertop

    # System monitoring
    btop
    dust        # Better du
    duf         # Better df
    procs       # Better ps

    # CLI utilities
    ripgrep
    fd
    eza
    bat
    jq      # JSON processor
    yq-go   # YAML processor
    httpie  # better curl for APIs
    nh      # nix-helper: better nixos-rebuild
    nvd     # nix version diff
    ncdu    # Interactive disk usage

    ]) ++ [
        inputs.zen-browser.packages.${pkgs.system}.default
    ];
}
