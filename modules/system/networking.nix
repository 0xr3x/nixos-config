{ config, pkgs, ... }:

{
  networking.hostName = "rex-nixos";

  # Enable networking
  networking.networkmanager.enable = true;

  # Faster boot - don't wait for network
  systemd.services.NetworkManager-wait-online.enable = false;

  # DNS settings for surfshark-vpn
  services.resolved = {
    enable = true;
    dnssec = "true";
    dnsovertls = "opportunistic";
    settings = {
      Resolve = {
        DNS = [ "1.1.1.1#cloudflare-dns.com" "8.8.8.8#dns.google" ];
        FallbackDNS = [ "9.9.9.9#dns.quad9.net" ];
      };
    };
  };
  networking.resolvconf.enable = false;
  networking.networkmanager.dns = "systemd-resolved";

  # WiFi MAC randomization for privacy
  networking.networkmanager.wifi.macAddress = "random";
  networking.networkmanager.wifi.scanRandMacAddress = true;

  # IPv6 privacy extensions (temporary addresses)
  networking.networkmanager.connectionConfig."ipv6.ip6-privacy" = 2;

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
