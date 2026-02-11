# Cursor Sandboxing Setup

This document explains how Cursor is sandboxed in your NixOS configuration for security.

## How It Works

### From KDE Launcher

When you click "Cursor" in your KDE application menu:

1. **`cursor-safe-gui`** launches
2. A KDE dialog appears asking you to select a project directory
3. Cursor opens with **only that directory accessible**
4. Your `~/.ssh`, `~/.aws`, and other projects are **blocked**

### From Terminal

```bash
# Recommended: Sandboxed (via firejail)
cursor ~/Documents/my-project

# Also works: specify path explicitly
cursor-safe ~/Documents/my-project
cursor-safe .  # Current directory

# Unsandboxed (use with caution)
cursor-unsafe
```

## Security Model

### What's Sandboxed

- **Cursor is restricted** to only the directory you specify
- Cannot access:
  - Your SSH keys (`~/.ssh`)
  - AWS credentials (`~/.aws`)
  - Other projects outside the whitelisted directory
  - System files
  - Other user files

### What's NOT Sandboxed

- Network access (Cursor needs internet for AI features)
- System calls required for normal operation
- GPU access (for performance)

## Directory Defaults

When launched from KDE without arguments:

1. **First choice**: KDE directory picker dialog
2. **Fallback**: `~/Documents` if it exists
3. **Last resort**: `~` (home directory)

## Firejail Profile

The sandboxing is enforced by firejail using:
- Profile: `/etc/firejail/cursor.profile`
- Whitelist: Only the specified directory
- Network: Enabled (required for AI features)

## Use Cases

### ✅ Safe Usage

```bash
# Working on a specific project
cursor-safe ~/Documents/client-project

# Testing unknown code in isolated directory
cursor-safe ~/Documents/test-repos/sketchy-repo
```

### ⚠️ Unsafe Usage

```bash
# Opens entire home directory (not recommended)
cursor-safe ~

# Bypasses all sandboxing (dangerous)
cursor-unsafe
```

## Terminal Aliases

Configured in `modules/home/shell.nix`:

```bash
cursor          # → cursor-safe (sandboxed)
cursor-unsafe   # → code-cursor-fhs (no sandbox)
```

## Desktop Integration

Configured in `home.nix`:

```nix
xdg.desktopEntries.cursor = {
  exec = "cursor-safe-gui %F";
  # ... overrides the default desktop entry
};
```

## Troubleshooting

### "Directory not accessible" error

Cursor is trying to access files outside the whitelisted directory. Either:
- Open Cursor with a broader directory scope
- Move the files into the project directory
- Use `cursor-unsafe` if you trust the code

### GUI picker doesn't appear

Make sure `kdialog` is available:
```bash
command -v kdialog
```

If missing, the script falls back to opening `~/Documents`.

## Comparison to dev-env

| Isolation | cursor-safe | dev-env |
|-----------|-------------|---------|
| **Filesystem** | Limited to one directory | Full container isolation |
| **Network** | Full access | Full access (opt-in ports) |
| **Tools** | Host system tools | Container-provided tools |
| **Best for** | IDE sandboxing | Project development |

Both can be used together:
- `cursor-safe` for IDE-level isolation
- `devenv shell` for project-level containerization
