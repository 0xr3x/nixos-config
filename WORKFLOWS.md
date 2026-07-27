# Development Workflows

Security-first development setup with containerized environments.

## Quick Reference

| Tool | Access | Use Case |
|------|--------|----------|
| **devenv** | Isolated container | Full dev environment per project |
| **code** (VS Code) | Remote-only | Connect to containers/SSH |

---

## Working on Projects

### Using dev-env (Recommended for Projects)

Each project gets its own isolated container with all dev tools:

```bash
cd ~/Documents/my-project

# Start development environment
devenv shell

# Inside container - you have:
# - Node.js (LTS) + pnpm
# - Rust (latest)
# - Python 3.12+ (via uv)
# - Foundry (forge, cast, anvil)
# - Neo4j graph database
# - Claude Code CLI
# - Playwright, GitHub CLI

# With specific ports
devenv shell --3000 --5173

# With Neo4j ports
devenv shell --neo4j
```

---

## First-Time Setup

### Set up dev-env

```bash
# Run once after rebuilding your system
setup-devenv

# This will:
# - Clone dev-env repo to ~/Documents/wonderland/dev-env
# - Check prerequisites (docker, npm, gh)
# - Create and encrypt .env file
# - Install dotenvx globally
```

### Add API Keys (Optional)

For enhanced dev-env features:

```bash
devenv-add-key
```

**Where to get keys:**
- **OpenRouter**: https://openrouter.ai/keys (for dev-env LLM hooks)
- **Claude Code OAuth Token**: Generate inside container (see below)

**To get Claude Code OAuth token:**
```bash
# 1. Start a dev environment
devenv shell

# 2. Inside container, run claude
claude

# 3. Complete OAuth in browser
# 4. Token is saved to ~/.claude/config.json in the volume
# 5. You can extract it and add via devenv-add-key for persistence
```

Auth persists in `claude-config` volume across rebuilds.

---

## dev-env Commands

### Basic Usage

```bash
devenv shell          # Start container and open shell
devenv status         # Check container status
devenv stop           # Stop container (preserves volumes)
devenv ps             # List all dev-env containers
```

### Convenience Aliases

```bash
dev                   # Short for 'devenv shell'
dev-status            # Check status
dev-ps                # List containers
```

### Port Management

```bash
devenv shell --3000              # Single port
devenv shell --3000 --5173       # Multiple ports
devenv shell --neo4j             # Neo4j ports (7474 + 7687)
devenv shell --all-ports         # All predefined ports
```

### Multi-Container Management

Each project directory gets its own container:

```bash
devenv ps                        # List all containers
devenv shell --takeover          # Force take ports from another
devenv shell --bg                # Start without ports
devenv activate                  # Take ports without entering
devenv deactivate                # Release ports, keep running
devenv stop-all                  # Stop all containers
```

### Maintenance

```bash
devenv rebuild        # Rebuild + restart (keeps volumes)
devenv rebuild-clean  # Full rebuild (wipes volumes)
devenv update         # Update tools inside container
devenv remove         # Remove container (keep volumes)
devenv destroy        # Remove container AND volumes
devenv clean          # Remove everything
```

---

## Inside dev-env Container

```bash
# Your project is mounted at ~/workspace
cd ~/workspace

# All tools are ready
node --version && pnpm --version
rustc --version && cargo --version
python3 --version && uv --version
forge --version && cast --version
claude --version

# Neo4j
neo4j start                     # Start database
cypher-shell                    # Query interface
# Browser: http://localhost:7474

# Python venv (auto-created)
source ~/workspace/.venv/bin/activate

# GitHub auth (if not done)
gh auth login
```

---

## Recommended Workflows

**For daily development:**
```bash
cd ~/projects/my-app
devenv shell --3000        # Full dev environment
```

**For untrusted code review:**
```bash
cd ~/Documents/review
devenv shell --bg          # Container without network ports
```

---

## Security Model

✅ **dev-env**: Full container isolation per project
✅ **VS Code**: Remote-only - can't access local files
✅ **SSH Agent**: Forwarded (keys never in container)

**Protected from:**
- ✅ AI accessing parent directories (../)
- ✅ Prompt injection stealing credentials
- ✅ Malicious code accessing other projects
- ✅ Supply chain attacks
- ✅ Code browsing your entire filesystem

**Now safe for BOTH trusted and untrusted projects!**

---

## Key Features

### dev-env Benefits

1. **Pre-configured tools** - No setup per project
2. **Persistent volumes** - Caches survive rebuilds
3. **SSH agent forwarding** - Keys never enter container
4. **Per-project isolation** - Each project gets own container
5. **Port management** - Opt-in exposure, conflict detection
6. **Maintained externally** - Wonderland team handles updates

---

## Troubleshooting

### dev-env Issues

```bash
# Container won't start
devenv status                    # Check what's happening
devenv logs                      # View container logs

# Port conflicts
devenv shell --bg                # Start without ports
devenv ps                        # See which container has ports
devenv shell --takeover          # Take ports from it

# Need a clean slate
devenv rebuild-clean             # Wipe everything, start fresh
```

### General Cleanup

```bash
# Clean up dev-env containers
devenv clean

# Clean up Docker/Podman
docker system prune -a --volumes
```

---

## Documentation

- **dev-env setup**: `docs/dev-env-setup.md`
- **System config**: `/home/rex/nixos-config/`
