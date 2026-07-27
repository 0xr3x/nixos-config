#!/usr/bin/env bash
# Pull flake.lock from /etc/nixos to ~/nixos-config

# /etc/nixos is not a git repo and is not the source of truth for anything but
# flake.lock (refreshed there by the weekly flake-update service, or by
# `nix flake lock` after an input change). A full-tree rsync used to run here,
# but /etc/nixos accumulates every file ever deleted from the repo - nothing
# ever prunes it - so it would resurrect stale files as untracked repo state.
cp /etc/nixos/flake.lock ~/nixos-config/flake.lock

echo "✓ Synced flake.lock from /etc/nixos to ~/nixos-config"
