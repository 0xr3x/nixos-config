{ config, pkgs, inputs, ... }:

{
  imports = [
    ./modules/home/terminal.nix
    ./modules/home/shell.nix
    ./modules/home/git.nix
    ./modules/home/devenv.nix
  ];

  programs.home-manager.enable = true;

  home.username = "rex";
  home.homeDirectory = "/home/rex";
  home.stateVersion = "25.11";
  home.sessionPath = [
    "$HOME/.local/bin"
    "/etc/nixos/scripts"  # For custom scripts like cursor-safe
  ];

  home.sessionVariables = {
    NH_FLAKE = "/etc/nixos";
  };

  # autostart 1password
  xdg.configFile."autostart/1password.desktop".source = "${pkgs._1password-gui}/share/applications/1password.desktop";

  # Override Cursor desktop entry to use sandboxed version
  xdg.desktopEntries.cursor = {
    name = "Cursor";
    genericName = "Text Editor";
    comment = "Code Editing. Redefined. (Sandboxed)";
    exec = "cursor-safe-gui %F";
    icon = "cursor";
    terminal = false;
    type = "Application";
    categories = [ "Utility" "TextEditor" "Development" "IDE" ];
    mimeType = [
      "text/plain"
      "text/x-chdr"
      "text/x-csrc"
      "text/x-c++hdr"
      "text/x-c++src"
      "text/x-java"
      "text/x-dsrc"
      "text/x-pascal"
      "text/x-perl"
      "text/x-python"
      "application/x-php"
      "application/x-httpd-php3"
      "application/x-httpd-php4"
      "application/x-httpd-php5"
      "application/xml"
      "text/html"
      "text/css"
      "text/x-sql"
      "text/x-diff"
    ];
    startupNotify = true;
    actions = {
      new-empty-window = {
        name = "New Empty Window";
        exec = "cursor-safe-gui";
      };
    };
  };

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
    gh          # GitHub CLI
    lazygit     # TUI for git
    docker-compose
    vscode      # Sandboxed via firejail for remote development only

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
