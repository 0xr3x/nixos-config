{ config, pkgs, ... }:

let
  # Some captive portals (BT Wi‑Fi's btwifi.com, Glide student halls' glide.co.uk) hand out a
  # DHCP domain but our global DNS override (1.1.1.1/8.8.8.8) bypasses the portal's own resolver,
  # so it never gets a chance to hijack queries and redirect to the sign-in page. For that link
  # only: drop the static DNS override so it falls back to the DHCP-provided (portal) resolver;
  # global settings stay as-is everywhere else. DNSSEC validation is handled globally via
  # `DNSSEC = "allow-downgrade"` below, so this script no longer needs to touch it per-link.
  resolvectl = "${config.systemd.package}/bin/resolvectl";
  captivePortalDispatcher = pkgs.writeShellScript "nm-captive-portal" ''
    set -eu
    # connectivity-change / dns-change pass an empty $1; a non-empty iface check would exit 1 and spam NM logs.
    iface="''${1:-}"
    action="''${2:?}"

    captive_portal_network() {
      # Query resolved's current domain state for the link rather than this event's env vars:
      # a dhcp6-change event carries no IP4_DOMAINS/DHCP4_DOMAIN_NAME even while still on the
      # same captive-portal network, which previously caused it to flip the override back off.
      local domains
      domains="$(${resolvectl} domain "$iface" 2>/dev/null || true)"
      for domain in btwifi.com glide.co.uk; do
        case "$domains" in *"$domain"*) return 0 ;; esac
      done
      # Glide's DHCP server advertises no domain option at all (both Glide_2.4 and uS-Glide),
      # so there's nothing for the check above to match on that network. Fall back to matching
      # the connection/SSID name, which NetworkManager passes to dispatcher scripts as CONNECTION_ID.
      case "''${CONNECTION_ID:-}" in *Glide*) return 0 ;; esac
      return 1
    }

    case "$action" in
      up|dhcp4-change|dhcp6-change)
        if [[ -z "$iface" ]]; then
          exit 0
        fi
        if captive_portal_network; then
          ${resolvectl} dns "$iface" "" || true
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
        # allow-downgrade: validate when the server supports DNSSEC, skip silently when it
        # doesn't. Strict "yes" kept breaking on unsigned local-only domains (router admin
        # pages, captive portals) on every new network - Glide, BT Wi-Fi, TP-Link's
        # tplinkwifi.net - and would keep doing so on every future one.
        DNSSEC = "allow-downgrade";
        DNSOverTLS = "opportunistic";
        DNS = [ "1.1.1.1#cloudflare-dns.com" "8.8.8.8#dns.google" ];
        FallbackDNS = [ "9.9.9.9#dns.quad9.net" ];
      };
    };
  };
  networking.resolvconf.enable = false;
  networking.networkmanager.dns = "systemd-resolved";

  networking.networkmanager.dispatcherScripts = [
    { source = captivePortalDispatcher; type = "basic"; }
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
