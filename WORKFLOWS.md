# Development Workflows

Security-first development setup with containerized untrusted code.

## Quick Reference

| Tool | Access | Use Case |
|------|--------|----------|
| **cursor** (sandboxed) | Project dir only | All development (default) |
| **cursor-unsafe** | Full filesystem | Emergency only |
| **code** (VS Code) | Remote-only | Connect to containers/SSH |
| **claude** | Current dir only | AI assistance (containerized) |
| **turtleclone** | Isolated | Clone untrusted repos |

---

## Working on Trusted Projects

```bash
# Open in Cursor (sandboxed to project directory)
cursor ~/Documents/my-project

# Cursor can now ONLY access:
# ✅ ~/Documents/my-project and subdirectories
# ❌ Parent directories, ~/.ssh, other projects

# Use Claude Code for AI
cd ~/Documents/my-project
claude chat "explain this function"

# Both Cursor and Claude are now sandboxed to project only!
```

---

## Cloning Untrusted Repos

```bash
# Clone into isolated container
turtleclone https://github.com/random/sketchy-repo

# List containers
turtlelist

# Open in VS Code Remote (easiest)
turtlecode turtle-sketchy-repo-1234567890

# Or enter container shell
turtleshell turtle-sketchy-repo-1234567890

# Inside container - fully isolated
cd /workspace/sketchy-repo
npm install && npm start

# Destroy when done
turtlenuke turtle-sketchy-repo-1234567890
```

---

## Claude Code Usage

```bash
cd ~/Documents/my-project

# Basic commands
claude chat "refactor this code"
claude /edit main.py "add error handling"
claude --help

# Limitations:
# - Only sees current directory (recursive)
# - Ephemeral (no state between runs)
# - Container destroyed after each use
```

**Authentication:**
Claude Code container is ephemeral. Pass API key via environment:

```bash
export ANTHROPIC_API_KEY="your-key"
claude chat "hello"
```

---

## VS Code Remote Development

VS Code is sandboxed - **cannot access local files** (by design).

```bash
# Connect to SSH
code --remote ssh-remote+myserver /path

# Connect to container
code --remote container+turtle-myproject-123

# List containers
podman ps
```

---

## Moving Files (Host ↔ Container)

```bash
# Container → Host
podman cp turtle-proj-123:/workspace/file.txt ~/Downloads/

# Host → Container  
podman cp ~/file.txt turtle-proj-123:/workspace/
```

---

## Turtle Helper Commands

```bash
# List all turtle containers
turtlelist

# Open VS Code Remote in container
turtlecode turtle-myproject-123 [/optional/path]

# Enter container shell
turtleshell turtle-myproject-123 [/optional/path]

# Destroy container + volume
turtlenuke turtle-myproject-123

# Manual cleanup (if needed)
podman stop $(podman ps -q --filter "name=turtle-")
podman volume prune
```

---

## Recommended Workflows

**For ALL development:**
```
cursor ~/Documents/project     # Sandboxed to project only
claude chat "help"             # Sandboxed to current dir
```

**For untrusted code review:**
```
turtleclone → turtlecode       # Double isolated
```

**Emergency full access (avoid):**
```
cursor-unsafe ~/Documents/     # No sandbox - use with caution
```

---

## Security Model

✅ **Cursor**: Sandboxed to project directory  
✅ **VS Code**: Remote-only - can't access local files  
✅ **Claude Code**: Containerized - only current dir  
✅ **turtleclone**: Isolated - trapped in container

**Protected from:**
- ✅ AI accessing parent directories (../)
- ✅ Prompt injection stealing credentials  
- ✅ Malicious repos accessing other projects
- ✅ Supply chain attacks
- ✅ Code browsing your entire filesystem

**Now safe for BOTH trusted and untrusted projects!**

---

## Key Limitations

1. Claude Code auth not persistent (use env var)
2. VS Code cannot open local files (intentional)
3. Containers have limited networking (security)
4. Container startup takes 10-30 seconds

---

## Troubleshooting

```bash
# Container won't start
podman logs turtle-myproject-123

# Check resources
podman stats

# Clean up everything
podman system prune -a --volumes

# SELinux issues
# Use :Z flag: -v "$PWD:/workspace:Z"
```
