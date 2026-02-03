{ config, pkgs, ... }:

{
  # Firewall
  networking.firewall = {
    enable = true;
    # Only allow what you need
    allowedTCPPorts = [ ];
    allowedUDPPorts = [ ];
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
      
      # Bluetooth controller
      allow id 8087:0033 # Intel Bluetooth device
      
      # Wireless mouse dongle
      allow id 32c2:0018 # 2.4G Wireless Receiver
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
