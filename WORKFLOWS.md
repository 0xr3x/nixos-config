# Development Workflows

This guide explains how to work with your sandboxed development setup.

## Quick Reference

| Tool | Access Level | Use Case |
|------|--------------|----------|
| **Cursor** | Full filesystem | Local development (trusted projects) |
| **VS Code** | Remote-only | Connect to containers/SSH |
| **Claude Code** | Current directory only | AI assistance (containerized) |
| **turtleclone** | Isolated containers | Clone untrusted repos |

## Scenarios

### 1. Working on Trusted Project in ~/Documents

```bash
# Use Cursor (full access)
cursor ~/Documents/my-project

# Use Claude Code for AI assistance
cd ~/Documents/my-project
claude chat "explain this function"
claude /status

# Note: Claude only sees files in ~/Documents/my-project
```

### 2. Cloning Untrusted Repository

```bash
# Clone into isolated container
turtleclone https://github.com/random/sketchy-repo

# Container name will be shown, e.g.: turtle-sketchy-repo-1702938475

# Option A: Work inside container via terminal
podman exec -it turtle-sketchy-repo-1702938475 bash
cd /workspace/sketchy-repo
npm install
npm start

# Option B: Use VS Code Remote-Containers
code --remote container+turtle-sketchy-repo-1702938475

# Option C: Use Cursor (needs manual setup)
# Not recommended - container is isolated for a reason!

# When done, nuke everything
podman rm -f turtle-sketchy-repo-1702938475
podman volume rm turtle-sketchy-repo-1702938475-data
```

### 3. Using Claude Code

```bash
# Navigate to your project
cd ~/Documents/my-project

# Use Claude (mounts current directory)
claude chat "refactor this code"
claude /edit main.py "add error handling"
claude --help

# Limitations:
# - Only sees files in current directory (and subdirectories)
# - Cannot access parent directories
# - Each invocation is ephemeral (no state preserved)
# - NOT logged into Anthropic by default (uses public API)
```

### 4. Anthropic Login for Claude

**Claude Code in container does NOT persist authentication.**

Each time you run `claude`, it's a fresh container. To authenticate:

```bash
# Option 1: Pass API key via environment
export ANTHROPIC_API_KEY="your-key-here"
claude chat "hello"

# Option 2: Mount claude config (if you have one)
# Add to shell function:
podman run --rm -it \
  -v "$PWD:/workspace:Z" \
  -v "$HOME/.claude:/root/.claude:Z" \
  -w /workspace \
  ghcr.io/anthropics/claude-code:latest \
  "$@"
```

**Recommendation:** Use API key in environment variable for security.

### 5. VS Code Remote Development

VS Code is sandboxed and can ONLY work remotely:

```bash
# Connect to SSH server
code --remote ssh-remote+myserver /path/on/remote

# Connect to turtle container
code --remote container+turtle-myproject-123

# Connect to any running container
podman ps  # Find container ID
code --remote container+<container-id>
```

**VS Code cannot open local files** - this is intentional for security.

### 6. Moving Files Between Host and Container

```bash
# Copy file FROM container TO host
podman cp turtle-myproject-123:/workspace/repo/output.txt ~/Downloads/

# Copy file FROM host TO container
podman cp ~/Documents/config.json turtle-myproject-123:/workspace/repo/

# Mount host directory into container (if needed)
podman run -v ~/Documents/shared:/mnt/shared:Z ...
```

## Recommended Workflows

### For Trusted Development
```
~/Documents/project → Cursor + Claude Code
```

### For Untrusted Code Review
```
turtleclone → VS Code Remote-Containers → Review in isolation
```

### For Quick Scripts/Testing
```
cd /tmp/experiment → Cursor or Claude → Disposable workspace
```

## Security Notes

- **Cursor**: Full access - only use for trusted projects
- **VS Code**: Remote-only - can't leak local files to remote servers
- **Claude Code**: Containerized - can't access secrets or other projects
- **turtleclone**: Fully isolated - malicious code can't escape

## Limitations

1. **Claude Code Authentication**: Not persistent across runs
2. **VS Code Local Files**: Cannot open (by design)
3. **Container Networking**: Limited (for security)
4. **File Permissions**: SELinux `:Z` flag handles this

## Tips

```bash
# List all turtle containers
podman ps -a --filter "name=turtle-"

# Stop all turtle containers
podman stop $(podman ps -q --filter "name=turtle-")

# Remove all turtle volumes
podman volume ls --filter "name=turtle-" -q | xargs podman volume rm

# Check container resource usage
podman stats

# View container logs
podman logs turtle-myproject-123
```
