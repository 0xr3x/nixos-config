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
    sudo = {
      # Don't use fprintAuth = true as it waits even after password entry
      # Instead, make fingerprint truly optional using rules
      rules.auth.fprintd = {
        order = config.security.pam.services.login.rules.auth.unix.order - 10;
        control = "sufficient";
        modulePath = "${pkgs.fprintd}/lib/security/pam_fprintd.so";
      };
    };
  };

  # Hardware video acceleration (Intel)
  hardware.graphics = {
    enable = true;
    extraPackages = with pkgs; [
      intel-media-driver
      intel-vaapi-driver
      libvdpau-va-gl
    ];
  };

  # Proprietary codecs and media libraries
  environment.systemPackages = with pkgs; [
    ffmpeg-full
    gst_all_1.gstreamer
    gst_all_1.gst-plugins-base
    gst_all_1.gst-plugins-good
    gst_all_1.gst-plugins-bad
    gst_all_1.gst-plugins-ugly
    gst_all_1.gst-libav
    x265
    libde265
    libheif
  ];

  # Bluetooth
  hardware.bluetooth = {
    enable = true;
    powerOnBoot = true;
  };

  # Hardware wallets
  hardware.ledger.enable = true;
  services.trezord.enable = true;

  # YubiKey: udev rules (hardware.yubikey was removed upstream)
  services.udev.packages = [ pkgs.yubikey-personalization ];
  # USB-serial dongles + ESP32-C3 CDC (Xteink X4) at 303a:1001 — Web Serial / esptool; see
  # https://github.com/crosspoint-reader/xteink-flasher/issues/4
  # SUBSYSTEMS=="usb" so ATTRS match the USB ancestor; ModemManager can grab ttyACM and break Web Serial
  services.udev.extraRules = ''
    ACTION!="remove", SUBSYSTEMS=="usb-serial", TAG+="uaccess"

    SUBSYSTEM=="tty", KERNEL=="ttyACM[0-9]*", SUBSYSTEMS=="usb", ATTRS{idVendor}=="303a", ATTRS{idProduct}=="1001", MODE="0660", GROUP="dialout", TAG+="uaccess", ENV{ID_MM_DEVICE_IGNORE}="1"
  '';
  # CCID smart card interface for PIV / ykman
  services.pcscd.enable = true;

  # Trezor uses an unsafe encryption library
  nixpkgs.config.permittedInsecurePackages = [
    "python3.13-ecdsa-0.19.1"
    "python3.12-ecdsa-0.19.1"
  ];

  # Firmware updates
  services.fwupd.enable = true;

  # Faster key repeat for developers
  services.xserver.autoRepeatDelay = 200;
  services.xserver.autoRepeatInterval = 30;

}
