{ config, pkgs, ... }:

{
  # Podman (rootless, daemonless containers for security)
  virtualisation.podman = {
    enable = true;
    dockerCompat = true;  # Alias docker -> podman
    defaultNetwork.settings.dns_enabled = true;
    autoPrune = {
      enable = true;
      dates = "weekly";
    };
  };
}
