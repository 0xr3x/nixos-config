# NixOS Configuration

Security-focused NixOS setup with container-first development workflow.

## System

- **OS**: NixOS unstable + Flakes
- **Desktop**: KDE Plasma 6 (Wayland)
- **Hardware**: ThinkPad (Intel, 40GB RAM, NVMe)
- **Security**: LUKS, USBGuard, Firejail, containerized dev
- **Battery**: TLP optimized (8-10h runtime)

## Structure

```
flake.nix               # Flake configuration
configuration.nix       # Core system settings
home.nix               # User packages
hardware-configuration.nix  # Generated (not in git)

modules/
├── system/
│   ├── desktop.nix      # KDE, fonts
│   ├── hardware.nix     # Audio, bluetooth, USB
│   ├── networking.nix   # Network, DNS
│   ├── security.nix     # Firewall, USBGuard, Firejail
│   ├── virtualisation.nix # Podman
│   └── power.nix        # TLP battery
└── home/
    ├── terminal.nix     # Kitty
    ├── shell.nix        # Bash, starship, tools
    └── git.nix          # Git config

scripts/
├── turtleclone         # Clone repos into containers
├── turtlelist          # List turtle containers
├── turtlecode          # Open VS Code Remote in container
├── turtlenuke          # Destroy container + volume
├── turtleshell         # Quick shell access
└── cursor-safe         # Launch Cursor sandboxed to directory
```

## Quick Start

```bash
# Clone
git clone git@github.com:0xr3x/nixos-config.git /etc/nixos

# Generate hardware config
sudo nixos-generate-config --show-hardware-config > /etc/nixos/hardware-configuration.nix

# Update home.nix with your username/email

# Build
sudo nixos-rebuild switch --flake /etc/nixos#rex-nixos
```

## Development Workflow

See [WORKFLOWS.md](WORKFLOWS.md) for detailed guide.

**Quick summary:**
- All development: Use `cursor` (sandboxed to project only)
- Untrusted repos: Use `turtleclone` → isolated containers
- VS Code: Remote-only (connects to containers/SSH)
- Emergency: `cursor-unsafe` for full filesystem access

## Key Commands

```bash
# System
rebuild      # nixos-rebuild switch
update       # Update all flake inputs
cleanup      # Remove old generations

# Battery
bat-check    # Battery status
bright       # Brightness control

# Containers
turtleclone <git-url>        # Clone repo into container
turtlelist                   # List containers
turtlecode <container>       # Open VS Code Remote
turtleshell <container>      # Enter container
turtlenuke <container>       # Destroy container

# Claude Code (containerized AI)
claude chat "explain this"   # Current dir only
```

## Security Features

✅ LUKS full disk encryption  
✅ USBGuard (USB device whitelist)  
✅ Firejail sandboxing (WPS, VS Code, Cursor)  
✅ Container-first untrusted code  
✅ Firewall (deny all by default)  
✅ 1Password integration  
✅ AI tools sandboxed (no ../ access)  

## Automation

- **Weekly updates**: Flake inputs auto-update
- **Garbage collection**: Weekly, 30+ day old generations removed
- **Systemd timers**: Configured for both

## Notes

- WPS Office: Sandboxed, no network access
- VS Code: Cannot access local files (remote-only)
- Cursor: Sandboxed to project directory (use cursor-unsafe for full access)
- Claude Code: Ephemeral containers
- Battery: 50% CPU limit on battery power

## Multi-Machine

1. Clone repo to new machine
2. Generate hardware-configuration.nix
3. Update hostname in networking.nix + flake.nix
4. Rebuild

## License

MIT
