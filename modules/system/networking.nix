{ config, pkgs, ... }:

let
  # BT Wi‑Fi (and similar) DHCP advertises ~btwifi.com but answers are not DNSSEC-valid; turn off
  # validation for that link only so global DNSSEC stays on everywhere else.
  resolvectl = "${config.systemd.package}/bin/resolvectl";
  btWifiDnssecDispatcher = pkgs.writeShellScript "nm-btwifi-dnssec" ''
    set -eu
    iface="''${1:?}"
    action="''${2:?}"

    bt_domain() {
      case "''${IP4_DOMAINS:-}" in *btwifi.com*) return 0 ;; esac
      case "''${IP6_DOMAINS:-}" in *btwifi.com*) return 0 ;; esac
      case "''${DHCP4_DOMAIN_NAME:-}" in *btwifi.com*) return 0 ;; esac
      return 1
    }

    case "$action" in
      up|dhcp4-change|dhcp6-change)
        if bt_domain; then
          ${resolvectl} dnssec "$iface" no || true
        else
          # Drop BT-only override when switching to another network (avoid sticky per-link "no").
          ${resolvectl} dnssec "$iface" yes || true
        fi
        ;;
    esac
  '';
in
{
  networking.hostName = "thinkpad";

  # Enable networking
  networking.networkmanager.enable = true;

  # Faster boot - don't wait for network
  systemd.services.NetworkManager-wait-online.enable = false;

  # DNS settings for surfshark-vpn
  services.resolved = {
    enable = true;
    settings = {
      Resolve = {
        DNSSEC = "yes";
        DNSOverTLS = "opportunistic";
        DNS = [ "1.1.1.1#cloudflare-dns.com" "8.8.8.8#dns.google" ];
        FallbackDNS = [ "9.9.9.9#dns.quad9.net" ];
      };
    };
  };
  networking.resolvconf.enable = false;
  networking.networkmanager.dns = "systemd-resolved";

  networking.networkmanager.dispatcherScripts = [
    { source = btWifiDnssecDispatcher; type = "basic"; }
  ];

  # WiFi MAC randomization for privacy
  networking.networkmanager.wifi.macAddress = "random";
  networking.networkmanager.wifi.scanRandMacAddress = true;

  # IPv6 privacy extensions (temporary addresses)
  networking.networkmanager.connectionConfig."ipv6.ip6-privacy" = 2;
  boot.kernel.sysctl."net.ipv6.conf.all.use_tempaddr" = 2;

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
