{ config, pkgs, ... }:

{
  # Firewall (deny-by-default)
  networking.firewall = {
    enable = true;
    allowedTCPPorts = [ 53317 ];
    allowedUDPPorts = [ 53317 ];
    logReversePathDrops = true;
    logRefusedConnections = true;
  };

  # USBGuard - protect against malicious USB devices
  services.usbguard = {
    enable = true;
    dbus.enable = true;
    implicitPolicyTarget = "block";
    rules = ''
      # Allow currently connected devices on first run
      allow id 1d6b:0002 # Linux Foundation 2.0 root hub
      allow id 1d6b:0003 # Linux Foundation 3.0 root hub
      
      # Built-in hardware
      allow id 30c9:0050 # Integrated RGB Camera
      allow id 27c6:6594 # Goodix fingerprint reader
      allow id 058f:9540 # EMV Smartcard Reader
      
      # Bluetooth controller
      allow id 8087:0033 # Intel Bluetooth device
      
      # Wireless mouse dongle
      allow id 32c2:0018 # 2.4G Wireless Receiver
      
      # Gaming Keyboard
      allow id 2442:0001 # Gaming Keyboard
      
      # Hardware wallets
      allow id 2c97:* # Ledger (Nano S/X/S+, Stax, Flex)
      allow id 534c:0001 # Trezor One
      allow id 1209:53c1 # Trezor Model T / Safe
    '';
  };

  # 1Password
  programs._1password.enable = true;
  programs._1password-gui = {
    enable = true;
    polkitPolicyOwners = [ "rex" ];
  };

  # SSH via 1Password agent
  programs.ssh.startAgent = false;
  programs.ssh.extraConfig = ''
    Host *
      IdentityAgent ~/.1password/agent.sock
  '';

  # Allow using 1password in zen browser
  environment.etc."1password/custom_allowed_browsers" = {
    text = ''
      zen
      zen-browser
    '';
    mode = "0755";
  };

  # Stricter default umask: PAM level + shell fallback for non-PAM shells (e.g. curl|bash)
  security.loginDefs.settings.UMASK = "077";
  environment.shellInit = "umask 077";

  # ARP spoofing protection
  boot.kernel.sysctl."net.ipv4.conf.all.arp_announce" = 2;
  boot.kernel.sysctl."net.ipv4.conf.all.arp_ignore" = 1;

  # Suppress OS info in login banner
  services.getty.greetingLine = "";
  environment.etc.issue.text = "";

  # Disable core dumps (can leak sensitive memory contents)
  systemd.coredump.enable = false;
  security.pam.loginLimits = [{
    domain = "*";
    type = "hard";
    item = "core";
    value = "0";
  }];

  # Firejail for WPS Office (no network access)
  programs.firejail.enable = true;

  environment.etc."firejail/wps.profile".text = ''
    net none
    private
    seccomp
    caps.drop all
  '';

  programs.firejail.wrappedBinaries = {
    wps = {
      executable = "${pkgs.wpsoffice}/bin/wps";
      profile = "/etc/firejail/wps.profile";
    };
    et = {
      executable = "${pkgs.wpsoffice}/bin/et";
      profile = "/etc/firejail/wps.profile";
    };
    wpp = {
      executable = "${pkgs.wpsoffice}/bin/wpp";
      profile = "/etc/firejail/wps.profile";
    };
    wpspdf = {
      executable = "${pkgs.wpsoffice}/bin/wpspdf";
      profile = "/etc/firejail/wps.profile";
    };
    wpm = {
      executable = "${pkgs.wpsoffice}/bin/wpm";
      profile = "/etc/firejail/wps.profile";
    };
  };
}
