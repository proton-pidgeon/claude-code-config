# Claude Code Configuration Sync

Cross-platform synchronization for your Claude Code settings, agents, skills, commands, and conversation history across multiple hosts.

## Quick Start

### Setup on Any Host (macOS, Linux, Windows)

```bash
bash <(curl -fsSL https://raw.githubusercontent.com/proton-pidgeon/claude-code-config/main/bootstrap-claude-config.sh) -r "https://github.com/proton-pidgeon/claude-code-config.git"
```

That's it! The script will:
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
- **[bootstrap-claude-config.sh](bootstrap-claude-config.sh)** - Setup script (runs automatically)
- **[sync-claude-config.sh](sync-claude-config.sh)** - Sync helper script

## Key Features

- **Multi-agent parallelization preferences** - Claude automatically uses parallel execution when beneficial
- **7 custom agents** - Code review, security, architecture, integration, and more
- **Cross-platform** - Works on macOS, Linux, Windows (with Git Bash/WSL)
- **Secure by default** - Credentials never synced, stored locally only
- **One-command setup** - Bootstrap any new host with a single command

## Repository

- **Visibility**: Private (contains conversation history)
- **Files Synced**: 62 configuration files
- **Hosts**: Deploy to unlimited hosts
- **Backup**: Automatic on setup

---

For detailed information, see [SYNC-README.md](SYNC-README.md)
