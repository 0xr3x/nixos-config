# NixOS Configuration

Personal NixOS setup with flakes and home-manager.

## System Specs

- **OS**: NixOS unstable
- **Desktop**: KDE Plasma 6 (Wayland)
- **Laptop**: Intel CPU, NVMe SSD, 40GB RAM
- **Security**: LUKS encryption, 1Password, firewall
- **Battery**: TLP optimized for 8-10h runtime

## Structure

flake.nix              # Flake inputs/outputs
configuration.nix      # Core system config
home.nix              # User packages & dotfiles
hardware-configuration.nix  # Generated per-machine (not in git)

modules/system/
├── desktop.nix       # KDE, fonts, GUI
├── hardware.nix      # Audio, bluetooth, printing
├── networking.nix    # Network, locale
├── security.nix      # Firewall, 1Password, Firejail
├── virtualisation.nix # Docker
└── power.nix         # TLP battery optimization

overlays/
├── default.nix
└── claude-code.nix   # Custom npx wrapper

## Quick Start

Clone repo:
git clone git@github.com:0xr3x/nixos-config.git /etc/nixos

Generate hardware config:
sudo nixos-generate-config --show-hardware-config > /etc/nixos/hardware-configuration.nix

Update home.nix with your details (username, email, SSH key)

Build:
sudo nixos-rebuild switch --flake /etc/nixos#rex-nixos

## Aliases

rebuild      # Rebuild system
update       # Update flake inputs and rebuild
cleanup      # Delete old generations (30+ days)
bat-check    # Battery status
bright       # Brightness control

## Notes

- Auto-updates: Weekly (Saturdays)
- Garbage collection: Weekly, removes 30+ day old generations
- WPS Office: Sandboxed without network access
- Battery: 50% CPU limit on battery, 6-8h normal / 8-10h with 30% brightness

## Multi-Machine Setup

1. Clone repo to new machine
2. Generate hardware-configuration.nix for that machine
3. Optionally: Change hostname in modules/system/networking.nix and update flake.nix
4. Rebuild

## License

MIT
