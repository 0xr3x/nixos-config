# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, inputs, ... }:

{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
      ./modules/system/desktop.nix
      ./modules/system/hardware.nix
      ./modules/system/security.nix
      ./modules/system/networking.nix
      ./modules/system/virtualisation.nix
      ./modules/system/power.nix
    ];

  nix.settings = {
    experimental-features = [ "nix-command" "flakes" ];
    download-buffer-size = 128 * 1024 * 1024;

    # Optimizations
    auto-optimise-store = true;
    trusted-users = [ "root" "@wheel" ];
    max-jobs = "auto";
    cores = 0;

    # Binary cache substituters
    substituters = [
      "https://cache.nixos.org"
      "https://nix-community.cachix.org"
    ];
    trusted-public-keys = [
      "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
      "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
    ];

    # Better error messages and debugging
    log-lines = 25;
    show-trace = true;
    keep-failed = true;
    keep-derivations = true;
    fallback = true;
  };

  # Automatic system updates
  system.autoUpgrade = {
    enable = true;
    flake = "/etc/nixos";
    flags = [
      "--update-input" "nixpkgs"
      "--commit-lock-file"
    ];
    dates = "weekly";
    allowReboot = false;
  };

  # Automatic garbage collection
  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 30d";
  };

  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.loader.timeout = 3;

  # Power management optimizations
  powerManagement.enable = true;

  boot.kernelParams = [
    "quiet"                # Less verbose boot messages
    "splash"               # Show splash screen
    "i915.enable_psr=1"    # Panel self-refresh - saves screen power
    "i915.enable_fbc=1"    # Framebuffer compression
    "i915.enable_guc=3"    # GuC/HuC firmware (better power management)
    "i915.fastboot=1"      # Faster boot, less power during boot
  ];

  # Plymouth boot splash
  boot.plymouth.enable = true;

  # user account.
  users.users.rex = {
    isNormalUser = true;
    description = "rex";
    extraGroups = [ "networkmanager" "wheel" "docker" "lp" "lpadmin" ];
    packages = with pkgs; [ ];
  };

  environment.systemPackages = with pkgs; [
    git
    wget
    curl
    unzip
    pciutils  # lspci
    usbutils  # lsusb
  ];

  # Shell configuration
  programs.bash.completion.enable = true;

  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "25.11"; # Did you read the comment?

}
