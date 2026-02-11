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
      
      # Built-in hardware
      allow id 30c9:0050 # Integrated RGB Camera
      allow id 27c6:6594 # Goodix fingerprint reader
      allow id 058f:9540 # EMV Smartcard Reader
      
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

  # Firejail profile for VS Code (REMOTE ONLY - no local files)
  environment.etc."firejail/vscode.profile".text = ''
    # Network access (needed for remote development)
    
    # Minimal filesystem - config only
    whitelist ''${HOME}/.vscode
    whitelist ''${HOME}/.config/Code
    whitelist ''${HOME}/.ssh/config
    whitelist /tmp
    
    # Block EVERYTHING else
    blacklist ''${HOME}/Documents
    blacklist ''${HOME}/Downloads  
    blacklist ''${HOME}/Projects
    blacklist ''${HOME}/.ssh/id_*
    blacklist ''${HOME}/.gnupg
    blacklist ''${HOME}/.password-store
    blacklist ''${HOME}/.aws
    blacklist ''${HOME}/.kube
    blacklist ''${HOME}/.docker
    blacklist ''${HOME}/.1password
    
    # System restrictions
    seccomp
    caps.drop all
    nonewprivs
    noroot
    
    # Disable dangerous features
    nodvd
    nogroups
    noinput
    notv
    nou2f
    novideo
    
    # Read-only SSH config (can see remotes, can't modify keys)
    read-only ''${HOME}/.ssh/config
  '';

  # Firejail profile for Cursor (restricted to project directory only)
  environment.etc."firejail/cursor.profile".text = ''
    # Network access (needed for AI features)
    
    # Only allow the directory being opened + config
    # This is set at runtime via --whitelist=$PROJECT_DIR
    noblacklist ''${HOME}
    blacklist ''${HOME}
    
    # Allow cursor config
    whitelist ''${HOME}/.cursor
    whitelist ''${HOME}/.config/Cursor
    whitelist /tmp
    
    # Deny sensitive locations explicitly
    blacklist ''${HOME}/.ssh
    blacklist ''${HOME}/.gnupg
    blacklist ''${HOME}/.password-store
    blacklist ''${HOME}/.aws
    blacklist ''${HOME}/.kube
    blacklist ''${HOME}/.docker
    blacklist ''${HOME}/.1password
    
    # System restrictions
    seccomp
    caps.drop all
    nonewprivs
    noroot
    
    # Disable dangerous features
    nodvd
    nogroups
    noinput
    notv
    nou2f
    novideo
  '';

  programs.firejail.wrappedBinaries = {
    wps = {
      executable = "''${pkgs.wpsoffice}/bin/wps";
      profile = "/etc/firejail/wps.profile";
    };
    et = {
      executable = "''${pkgs.wpsoffice}/bin/et";
      profile = "/etc/firejail/wps.profile";
    };
    wpp = {
      executable = "''${pkgs.wpsoffice}/bin/wpp";
      profile = "/etc/firejail/wps.profile";
    };
    wpspdf = {
      executable = "''${pkgs.wpsoffice}/bin/wpspdf";
      profile = "/etc/firejail/wps.profile";
    };
    wpm = {
      executable = "''${pkgs.wpsoffice}/bin/wpm";
      profile = "/etc/firejail/wps.profile";
    };
    
    # VS Code (locked down for remote-only use)
    code = {
      executable = "''${pkgs.vscode}/bin/code";
      profile = "/etc/firejail/vscode.profile";
    };
  };
}
