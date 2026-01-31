{ config, pkgs, ... }:

{
  networking.hostName = "rex-nixos";

  # Enable networking
  networking.networkmanager.enable = true;

  # Networking settings required for surfshark-vpn
  services.resolved.enable = true;
  networking.resolvconf.enable = false;
  networking.networkmanager.dns = "systemd-resolved";

  # Time zone
  time.timeZone = "Europe/London";

  # Locale settings
  i18n.defaultLocale = "en_GB.UTF-8";
  i18n.extraLocaleSettings = {
    LC_ADDRESS = "en_GB.UTF-8";
    LC_IDENTIFICATION = "en_GB.UTF-8";
    LC_MEASUREMENT = "en_GB.UTF-8";
    LC_MONETARY = "en_GB.UTF-8";
    LC_NAME = "en_GB.UTF-8";
    LC_NUMERIC = "en_GB.UTF-8";
    LC_PAPER = "en_GB.UTF-8";
    LC_TELEPHONE = "en_GB.UTF-8";
    LC_TIME = "en_GB.UTF-8";
  };
}
