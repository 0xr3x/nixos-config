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
│   ├── desktop.nix        # KDE, fonts
│   ├── hardware.nix       # Audio, bluetooth, USB
│   ├── networking.nix     # Network, DNS
│   ├── security.nix       # Firewall, USBGuard, Firejail
│   ├── virtualisation.nix # Podman/Docker
│   └── power.nix          # TLP battery
└── home/
    ├── terminal.nix       # Kitty
    ├── shell.nix          # Bash, starship, tools
    ├── git.nix            # Git config
    └── devenv.nix         # dev-env integration

docs/
├── WORKFLOWS.md           # Complete development workflows
└── dev-env-setup.md       # dev-env setup guide
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
- **Development**: Use `devenv shell` for full dev environment per project

## Key Commands

```bash
# System
rebuild      # nixos-rebuild switch
update       # Update all flake inputs
cleanup      # Remove old generations

# Battery
bat-check    # Battery status
bright       # Brightness control

# Development Environments
devenv shell           # Start dev container for current project
devenv shell --3000    # With port 3000 exposed
devenv ps              # List all dev containers
devenv stop            # Stop current project's container
setup-devenv           # First-time dev-env setup
devenv-add-key         # Add API keys (optional)

# Convenience
dev                    # Short for 'devenv shell'
dev-status             # Check container status

# Sync repo ↔ /etc/nixos (nh uses /etc/nixos)
./apply-to-system.sh   # Push .nix changes; does not overwrite hardware-configuration.nix or flake.lock
./sync-from-system.sh  # Pull from system (includes flake.lock — run after update)
```

After changing `flake.nix` inputs: apply → `sudo nix flake lock` in `/etc/nixos` → rebuild → sync-from-system.

## Security Features

✅ LUKS full disk encryption  
✅ USBGuard (USB device whitelist)  
✅ Firejail sandboxing (WPS Office)  
✅ Container-first development (dev-env)  
✅ Per-project isolated containers  
✅ SSH agent forwarding (keys never in containers)  
✅ Firewall (deny all by default)  
✅ 1Password integration  
✅ Opt-in port exposure (nothing exposed by default)  

## Automation

- **Weekly updates**: Flake inputs auto-update
- **Garbage collection**: Weekly, 30+ day old generations removed
- **Systemd timers**: Configured for both

## Notes

- **WPS Office**: Sandboxed, no network access
- **dev-env**: Full dev stack per project (Node, Rust, Python, Foundry, Neo4j, Claude Code)
- **VS Code**: Remote-only (connects to containers/SSH)
- **Battery**: 50% CPU limit on battery power
- **API Keys**: Encrypted with dotenvx in dev-env

## Multi-Machine

1. Clone repo to new machine
2. Generate hardware-configuration.nix
3. Update hostname in networking.nix + flake.nix
4. Rebuild

## License

MIT
