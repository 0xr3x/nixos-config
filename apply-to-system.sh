#!/usr/bin/env bash
# Apply config from ~/nixos-config to /etc/nixos

sudo rsync -av --exclude='hardware-configuration.nix' --exclude='.git' --exclude='result*' --exclude='*.sh' ~/nixos-config/ /etc/nixos/

echo "✓ Applied ~/nixos-config to /etc/nixos"
echo "Run 'rebuild' to activate changes"
