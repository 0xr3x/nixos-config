{ config, pkgs, ... }:

{
  # X11 and Desktop Environment
  services.xserver.enable = true;
  services.displayManager.sddm.enable = true;
  services.desktopManager.plasma6.enable = true;

  # Touchpad gestures and settings
  services.libinput = {
    enable = true;
    touchpad = {
      tapping = true;
      naturalScrolling = true;
      clickMethod = "clickfinger";
    };
  };

  # Configure keymap
  services.xserver.xkb = {
    layout = "gb";
  };
  console.keyMap = "uk";

  # KDE packages
  environment.systemPackages = with pkgs; [
    # bluetooth support
    kdePackages.bluez-qt
    kdePackages.plasma-pa
  ];

  # Bluetooth GUI manager
  services.blueman.enable = true;

  # Wayland environment variables
  environment.sessionVariables = {
    NIXOS_OZONE_WL = "1";
    ELECTRON_OZONE_PLATFORM_HINT = "auto";
    MOZ_ENABLE_WAYLAND = "1";      # Firefox Wayland
    QT_QPA_PLATFORM = "wayland";
    SDL_VIDEODRIVER = "wayland";
    TERMINAL = "kitty";  # Set default terminal
  };

  # flatpak
  services.flatpak.enable = true;
  xdg.portal.enable = true;

  # appimages
  programs.appimage = {
    enable = true;
    binfmt = true;
  };

  # OBS Studio
  programs.obs-studio = {
    enable = true;
    plugins = with pkgs.obs-studio-plugins; [
      wlrobs  # Wayland screen capture
    ];
  };

  # Firefox
  programs.firefox.enable = true;

  # Fonts
  fonts.packages = with pkgs; [
    noto-fonts
    noto-fonts-cjk-sans
    noto-fonts-color-emoji
    liberation_ttf
    fira-code
    fira-code-symbols
    jetbrains-mono
    nerd-fonts.fira-code
    nerd-fonts.jetbrains-mono
  ];
}
