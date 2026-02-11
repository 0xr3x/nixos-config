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
  
  # Enable rootless containers
  virtualisation.containers.enable = true;
  
  # Configure subuid/subgid for rootless containers
  users.users.rex = {
    extraGroups = [ "podman" ];
    subUidRanges = [{ startUid = 100000; count = 65536; }];
    subGidRanges = [{ startGid = 100000; count = 65536; }];
  };
}
