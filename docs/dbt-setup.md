# dbt Fusion Setup

This document explains how dbt is set up on this system.

## What's Installed

dbt runs on the **dbt Fusion engine** (Rust CLI + LSP), not the older Python
`dbt-core`. Since Fusion isn't in nixpkgs yet, it's packaged via a personal
fork of [rfaulhaber/dbt-fusion-nix](https://github.com/0xr3x/dbt-fusion-nix),
wired in as a flake input (`flake.nix`) and applied as an overlay so the
unfree-licensed package picks up this system's existing `allowUnfree = true`:

```nix
# flake.nix
dbt-fusion = {
  url = "github:0xr3x/dbt-fusion-nix";
  inputs.nixpkgs.follows = "nixpkgs";
};
# ...
nixpkgs.overlays = [ dbt-fusion.overlays.default ];
```

```nix
# home.nix
dbt      # dbt Fusion CLI
dbt-lsp  # dbt Fusion language server
```

This keeps `dbt`/`dbt-lsp` fully Nix-managed — reproducible, and not a
curl-installed binary shadowing itself on `$PATH`.

**Updating:** the fork's upstream (`rfaulhaber/dbt-fusion-nix`) runs a nightly
GitHub Action that refreshes `static.json` with new release hashes. Run
`./apply-to-system.sh && (cd /etc/nixos && sudo nix flake lock --update-input dbt-fusion) && rebuild`
to pick up a new version.

## Helper Commands

Two scaffolding helpers live in `modules/home/shell.nix`, installed to
`~/.local/bin/`:

```bash
dbt-new <project-name>   # scaffold a new project in ~/Documents/dbt/<name>
dbt-clone-sample          # clone the Jaffle Shop sample project
```

`dbt-new` creates a minimal `dbt_project.yml` and registers a local DuckDB
profile in `~/.dbt/profiles.yml` (without clobbering existing entries), then
initializes git. No per-project Python venv is needed — Fusion is a single
global binary.

```bash
dbt-new my_analytics
cd ~/Documents/dbt/my_analytics
dbt build
```

```bash
dbt-clone-sample
cd ~/Documents/dbt/jaffle_shop
dbt build
dbt compile --write-catalog   # generates catalog.json; docs generate/serve are deprecated in Fusion
```

## VS Code

VS Code (`vscode` package) is installed for the
[dbt VS Code extension](https://docs.getdbt.com/docs/install-dbt-extension),
which unlocks Fusion's interactive features (autocomplete, inline errors,
lineage) directly in the editor.
