# Development Workflows

Security-first development setup with containerized untrusted code.

## Quick Reference

| Tool | Access | Use Case |
|------|--------|----------|
| **Cursor** | Full filesystem | Trusted local projects |
| **VS Code** | Remote-only | Connect to containers/SSH |
| **Claude Code** | Current dir only | AI assistance (containerized) |
| **turtleclone** | Isolated | Untrusted repos |

---

## Working on Trusted Projects

```bash
# Open in Cursor
cursor ~/Documents/my-project

# Use Claude Code for AI
cd ~/Documents/my-project
claude chat "explain this function"
claude /status

# Note: Claude only sees current directory
```

---

## Cloning Untrusted Repos

```bash
# Clone into isolated container
turtleclone https://github.com/random/sketchy-repo

# List containers
turtlelist

# Enter container shell
turtleshell turtle-sketchy-repo-1234567890

# Inside container - fully isolated
cd /workspace/sketchy-repo
npm install && npm start

# Use VS Code Remote
code --remote container+turtle-sketchy-repo-1234567890

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

**Trusted work:**  
`~/Documents/project` → Cursor + Claude Code

**Untrusted review:**  
`turtleclone` → VS Code Remote → Review isolated

**Quick experiments:**  
`/tmp/test` → Cursor or Claude → Disposable

---

## Security Model

✅ **Cursor**: Full access - trusted projects only  
✅ **VS Code**: Remote-only - can't leak local files  
✅ **Claude Code**: Containerized - no access to secrets  
✅ **turtleclone**: Isolated - malicious code trapped

**Protected from:**
- Prompt injection attacks
- Malicious repos stealing credentials  
- AI accessing sensitive files
- Supply chain attacks

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
