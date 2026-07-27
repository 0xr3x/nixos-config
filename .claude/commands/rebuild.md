---
description: Apply this repo to /etc/nixos and rebuild the system
---

Apply the current repo state to `/etc/nixos` and rebuild.

This repo is the editable copy; `/etc/nixos` is what `nh` actually builds from
(`NH_FLAKE=/etc/nixos`). The two must be synced explicitly.

## Steps

1. Show me `git status` and confirm the working tree is in the state I want to
   apply. `apply-to-system.sh` copies the working tree, not `HEAD` — uncommitted
   changes are included.

2. Verify the Nix files at least parse before touching the system:
   `nix-instantiate --parse configuration.nix home.nix` and any changed module.
   A full `nix eval` of the flake will NOT work from this copy, because
   `hardware-configuration.nix` is gitignored and only exists in `/etc/nixos`.

3. Run `./apply-to-system.sh`. This needs root, and sudo on this machine
   requires a fingerprint or password at an interactive terminal — so I must run
   it myself. Print the command and stop; do not try to run it for me.

4. If `flake.nix` inputs changed, the lock must be regenerated in `/etc/nixos`:
   `(cd /etc/nixos && sudo nix flake lock)` — again, mine to run.

5. `rebuild` (`nh os switch`) — mine to run.

6. `./sync-from-system.sh` to pull `flake.lock` back into this repo, then show me
   the resulting diff so the lock change can be committed.

## Notes

- `apply-to-system.sh` excludes `hardware-configuration.nix`, `flake.lock`,
  `.git`, `result*` and `*.sh`.
- Never edit `/etc/nixos` directly; it is overwritten by step 3.
- If `flake.lock` is missing from this repo, stop and tell me — rebuilding
  without it means an unpinned build.
