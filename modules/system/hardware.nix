{ config, pkgs, ... }:

{
  # Enable CUPS to print documents
  services.printing = {
    enable = true;
    browsed.enable = false;
    openFirewall = true;
  };

  services.avahi = {
    enable = true;
    nssmdns4 = true;
    openFirewall = true;
  };

  # Enable sound with pipewire
  services.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    wireplumber.enable = true;
  };

  # Fingerprint reader
  services.fprintd.enable = true;
  security.pam.services = {
    login.fprintAuth = true;
    # Make sudo fingerprint sufficient (optional), not required
    sudo.text = ''
      auth sufficient pam_fprintd.so
      auth include system-auth
      account include system-auth
      password include system-auth
      session include system-auth
    '';
  };

  # Bluetooth
  hardware.bluetooth = {
    enable = true;
    powerOnBoot = true;
  };

  # Hardware wallets
  hardware.ledger.enable = true;
  services.trezord.enable = true;

  # Trezor uses an unsafe encryption library
  nixpkgs.config.permittedInsecurePackages = [
    "python3.13-ecdsa-0.19.1"
  ];

  # Firmware updates
  services.fwupd.enable = true;

  # Faster key repeat for developers
  services.xserver.autoRepeatDelay = 200;
  services.xserver.autoRepeatInterval = 30;

}
