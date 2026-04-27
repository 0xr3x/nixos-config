{ ... }:

{
  # Brave reads one flag per line (same as Chromium). Keeps Ozone on Wayland and
  # avoids tiny /dev/shm issues without touching the sandbox.
  xdg.configFile."BraveSoftware/Brave-Browser/chromium-flags.conf".text = ''
    --ozone-platform=wayland
    --disable-dev-shm-usage
  '';
}
