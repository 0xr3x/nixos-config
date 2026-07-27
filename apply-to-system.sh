#!/usr/bin/env bash
# Apply config from ~/nixos-config to /etc/nixos

sudo rsync -av \
  --chown=root:root \
  --chmod=Du=rwx,Dgo=rx,Fu=rw,Fgo=r \
  --exclude='hardware-configuration.nix' \
  --exclude='flake.lock' \
  --exclude='.git' \
  --exclude='result*' \
  --exclude='*.sh' \
  ~/nixos-config/ /etc/nixos/

echo "✓ Applied ~/nixos-config to /etc/nixos (flake.lock unchanged — run sync-from-system after update)"
echo "Run 'rebuild' to activate changes"
