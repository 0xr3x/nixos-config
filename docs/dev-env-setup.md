# Dev-env Declarative Setup

This document explains the declarative dev-env integration added to your NixOS configuration.

## What Was Added

### 1. New Module: `modules/home/devenv.nix`
- Installs the `devenv` command wrapper
- Adds convenience aliases (`dev`, `dev-status`, `dev-ps`)
- Provides `setup-devenv` function for first-time setup
- Configures Docker/Podman socket location

### 2. Updated Files
- `home.nix`: Added import for `devenv.nix` module
- `virtualisation.nix`: Already has proper subuid/subgid configuration

## First-Time Setup

After rebuilding your system, run:

```bash
# 1. Rebuild NixOS (applies all changes)
nh os switch

# 2. Run the setup helper
setup-devenv

# This will:
#   - Clone dev-env repo to ~/dev-env
#   - Check prerequisites (docker, npm, gh)
#   - Create and encrypt .env file
#   - Install dotenvx globally
```

## Usage

### Start a Development Environment

```bash
# Navigate to any project
cd ~/projects/my-app

# Start dev environment (auto-creates project-specific container)
devenv shell

# Start with specific ports
devenv shell --3000 --5173

# Start with Neo4j ports
devenv shell --neo4j

# Start with all predefined ports
devenv shell --all-ports
```

### Convenience Aliases

```bash
dev              # Short for 'devenv shell'
dev-status       # Check container status
dev-ps           # List all dev-env containers
```

### Managing Containers

```bash
devenv ps                # List all containers
devenv stop              # Stop current project's container
devenv stop-all          # Stop all dev-env containers
devenv rebuild           # Rebuild container (keeps data)
devenv rebuild-clean     # Full rebuild (wipes volumes)
devenv destroy           # Remove container and volumes
```

## What You Get

Each project gets an isolated container with:

- **Node.js** (LTS via nvm) + pnpm
- **Rust** (latest stable via rustup)
- **Python** 3.12+ (via uv)
- **Foundry** (forge, cast, anvil, chisel)
- **Neo4j** graph database
- **Claude Code** CLI
- **Playwright** browser automation
- **GitHub CLI** (gh)
- **Oh My Zsh** with plugins

## Security Features

- Isolated per-project containers
- SSH agent forwarding (keys never in container)
- Opt-in port exposure (nothing exposed by default)
- Persistent volumes for caches (survive rebuilds)
- Rootless by default (via Podman)

## Directory Structure

```
~/dev-env/                        # dev-env repository
  ├── Dockerfile                   # Container definition
  ├── docker-compose.yml           # Service config
  ├── Makefile                     # CLI implementation
  ├── .env                         # Your config (encrypted)
  └── .env.keys                    # Decryption key (KEEP SAFE!)

~/your-project/                    # Your work
  └── (mounted to /home/developer/workspace in container)
```

## Managing API Keys

### Adding Keys

After running `setup-devenv`, add your API keys:

```bash
devenv-add-key
```

This will:
1. Prompt you for OpenRouter and Anthropic API keys
2. Update the `.env` file
3. Re-encrypt it with dotenvx

### Manual Method

If you prefer to edit directly:

```bash
cd ~/dev-env

# Edit .env file (add your keys)
nano .env

# Re-encrypt
dotenvx encrypt
```

### Where to Get Keys

- **OpenRouter API Key**: https://openrouter.ai/keys
  - Used by dev-env hooks for LLM features
  - Optional for basic development

- **Anthropic API Key**: https://console.anthropic.com/
  - Used by Claude Code CLI inside containers
  - Optional - only needed if using Claude CLI

### Security Notes

- ⚠️ **Keep `.env.keys` safe** - It's your decryption key
- ✅ `.env.keys` should be in `.gitignore` (don't commit!)
- ✅ The encrypted `.env` file can be safely committed
- ✅ Keys are only accessible inside dev-env containers

## Troubleshooting

### Container won't start
```bash
devenv status    # Check what's happening
devenv logs      # View logs
```

### Port conflicts
```bash
devenv shell --bg         # Start without ports
devenv shell --takeover   # Take ports from another container
```

### Need fresh start
```bash
devenv rebuild-clean
```

## Comparison to turtleclone

| Feature | turtleclone | dev-env |
|---------|-------------|---------|
| **Setup** | Simple script | Declarative NixOS module |
| **Tools** | Basic (git, node, python) | Comprehensive dev stack |
| **Maintenance** | Manual | Managed by wonderland team |
| **Security** | High isolation | High + SSH agent forwarding |
| **Per-project** | Yes | Yes + multi-container mgmt |
| **Claude integration** | No | Yes (hooks, context) |

## Next Steps

1. Rebuild NixOS: `nh os switch`
2. Run setup: `setup-devenv`
3. Try it: `cd ~/projects/test && devenv shell`
4. Keep using turtleclone for quick one-off testing if you prefer

## Notes

- The `devenv` command works from any directory
- Each project directory gets its own isolated container
- Containers automatically start on first `devenv shell`
- You can still use `turtleclone` for simple isolation needs
