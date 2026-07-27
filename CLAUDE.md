# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What This Is

Personal NixOS configuration for a ThinkPad (x86_64-linux). Flake-based with home-manager. Security-hardened with container-first development workflow.

## Key Commands

```bash
# Build and apply (on the actual machine, not in dev containers)
sudo nixos-rebuild switch --flake /etc/nixos#thinkpad

# Using the nh helper alias (preferred)
rebuild          # nh os switch
update           # nh os switch --update
cleanup          # nh clean all --keep 5

# Sync between repo copy and /etc/nixos
./apply-to-system.sh   # ~/nixos-config → /etc/nixos (.nix only; excludes hardware-configuration.nix, flake.lock)
./sync-from-system.sh  # /etc/nixos → ~/nixos-config (includes flake.lock — run after update)

# After changing flake inputs in the repo:
./apply-to-system.sh && (cd /etc/nixos && sudo nix flake lock) && rebuild && ./sync-from-system.sh
```

There are no tests or linters configured for this repo. Validation happens at `nixos-rebuild switch` time.

## Architecture

**Flake entry point**: `flake.nix` defines a single NixOS configuration (`thinkpad`) using nixpkgs-unstable + home-manager. Inputs include a stable nixpkgs pin (for packages needing older versions like trezorctl) and a custom zen-browser flake.

**Two-layer module split**:
- `modules/system/*.nix` — NixOS system-level config (imported by `configuration.nix`)
- `modules/home/*.nix` — Home Manager user-level config (imported by `home.nix`)

This separation matters: system modules use `{ config, pkgs, ... }` and configure services/boot/networking. Home modules configure user programs and dotfiles.

**Security model** (central design concern):
- Firewall deny-by-default, USBGuard blocks unknown USB devices (`security.nix`)
- WPS Office firejailed with no network (`security.nix`)
- Podman with rootless containers, docker-compat (`virtualisation.nix`)
- 1Password SSH agent (no raw SSH keys on disk), commit signing via `op-ssh-sign` (`git.nix`)
- Strict umask 077 at both PAM and shell level (`security.nix`)
- DNS-over-TLS, WiFi MAC randomization, IPv6 privacy extensions (`networking.nix`)

**Development environments**: Two container approaches coexist:
- `devenv` command (in `modules/home/devenv.nix`) — wraps a Makefile-based tool cloned from the `github:0xr3x/devc` repo (personal fork, formerly defi-wonderland/dev-env). Per-project containers with opt-in port exposure. Note: the *repo* is named `devc`, distinct from the `devc` *command* below
- `devc` command (in `modules/home/claude-devcontainer.nix`) — wraps Trail of Bits' claude-code-devcontainer

## Conventions

- Commit messages use conventional format: `feat:`, `fix:`, `security:`, `refactor:`, `power:`, `chore:`
- `hardware-configuration.nix` is machine-generated and excluded from git (see `.gitignore`)
- Shell aliases redefine common tools: `ls`→`eza`, `cat`→`bat`, `grep`→`rg`, `find`→`fd`, `cd`→`z` (zoxide)
- The flake hostname is `thinkpad`; the system user is `rex`

## AI tooling

`claude-code` is installed declaratively via `home.packages` in `home.nix` and
tracks nixpkgs — there is no pinned version or hash to bump, and the weekly
`flake-update` timer keeps it current. Do not install it via `curl | bash`; that
shadows the Nix-managed binary with an unmanaged one in `~/.local/bin`.

`.claude/` in this repo is committed and shared:

- `.claude/settings.json` — permission allowlist for the read-only commands used
  when working here, plus denies for credential paths (`~/.ssh`, `~/.1password`,
  `~/.claude/.credentials.json`)
- `.claude/commands/rebuild.md` — the `/rebuild` flow for applying this repo to
  `/etc/nixos`
- `.claude/settings.local.json` is gitignored, for personal overrides

Note that `sudo` on this machine needs a fingerprint or password at an
interactive terminal, so an agent cannot run `apply-to-system.sh`,
`nix flake lock` in `/etc/nixos`, or `rebuild`. Those steps are always handed
back to the user.

### MCP

No MCP servers are registered globally, deliberately. `freecad-mcp`
(`~/.local/bin/freecad-mcp`, installed as a uv tool) connects to a **running
FreeCAD instance**, so registering it at user scope would make it fail to start
on every unrelated session. Register it only while doing CAD work:

```bash
freecad-mcp --check                                  # confirm FreeCAD reachable
claude mcp add freecad -- freecad-mcp --transport stdio
claude mcp remove freecad                            # when done
```
