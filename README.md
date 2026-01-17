# Claude Code Configuration Sync

Cross-platform synchronization for your Claude Code settings, agents, skills, commands, and conversation history across multiple hosts.

## Prerequisites

### Install Claude CLI

**Linux / macOS / WSL:**
```bash
curl -fsSL https://claude.ai/install.sh | sh
```

**Windows PowerShell:**
```powershell
irm https://claude.ai/install.ps1 | iex
```

After installation, restart your terminal and verify with: `claude --version`

## Quick Start

### Linux / macOS / WSL Setup

One-line command to download and execute the bootstrap script:

```bash
bash <(curl -fsSL https://raw.githubusercontent.com/proton-pidgeon/claude-code-config/main/bootstrap-claude-config.sh) -r "https://github.com/proton-pidgeon/claude-code-config.git"
```

### Windows PowerShell Setup

One-line command to download and execute the bootstrap script:

```powershell
iwr -useb https://raw.githubusercontent.com/proton-pidgeon/claude-code-config/main/bootstrap-claude-config.ps1 | iex; Bootstrap-ClaudeConfig -RepoUrl "https://github.com/proton-pidgeon/claude-code-config.git"
```

**Note:** You may need to enable script execution first:
```powershell
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
```

### What the Bootstrap Script Does

The script will:
- Clone your configuration repository
- Preserve any existing credentials
- Create host-specific settings
- Verify everything is working

### After Setup

```bash
# Log in to Claude
claude auth login

# Verify configuration
cd ~/.claude
./sync-claude-config.sh status
```

## Daily Workflow

### Before switching hosts
```bash
cd ~/.claude
./sync-claude-config.sh push "Description of changes"
```

### After switching hosts
```bash
cd ~/.claude
./sync-claude-config.sh pull
```

## What Gets Synced

✅ Configuration, agents, skills, commands, settings, conversation history
❌ Credentials, large session data, plugin caches (kept local for security)

## Documentation

- **[QUICK-START.md](QUICK-START.md)** - Quick reference guide
- **[SYNC-README.md](SYNC-README.md)** - Complete documentation
- **[bootstrap-claude-config.sh](bootstrap-claude-config.sh)** - Setup script for Linux/macOS/WSL
- **[bootstrap-claude-config.ps1](bootstrap-claude-config.ps1)** - Setup script for Windows PowerShell
- **[sync-claude-config.sh](sync-claude-config.sh)** - Sync helper script

## Key Features

- **Multi-agent parallelization preferences** - Claude automatically uses parallel execution when beneficial
- **7 custom agents** - Code review, security, architecture, integration, and more
- **Cross-platform** - Works on macOS, Linux, WSL, and Windows (native PowerShell support)
- **Secure by default** - Credentials never synced, stored locally only
- **One-command setup** - Bootstrap any new host with a single command

## Repository

- **Visibility**: Private (contains conversation history)
- **Files Synced**: 62 configuration files
- **Hosts**: Deploy to unlimited hosts
- **Backup**: Automatic on setup

---

For detailed information, see [SYNC-README.md](SYNC-README.md)
