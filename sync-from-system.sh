#!/usr/bin/env bash
# Sync config from /etc/nixos to ~/nixos-config

rsync -av --exclude='hardware-configuration.nix' --exclude='.git' --exclude='result*' /etc/nixos/ ~/nixos-config/

echo "✓ Synced from /etc/nixos to ~/nixos-config"
