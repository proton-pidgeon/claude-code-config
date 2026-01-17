# Quick Start Guide - Claude Code Config Sync

## Your Setup is Ready! ✓

Repository: `https://github.com/proton-pidgeon/claude-code-config`
Status: **PRIVATE** (secure for conversation history)
Synced files: **60 files** including settings, history, agents, skills, commands

---

## Daily Sync Commands

### Before Switching Hosts
Push your changes to save them:
```bash
cd ~/.claude
./sync-claude-config.sh push "Update: description of changes"
```

### After Switching Hosts
Pull the latest configuration:
```bash
cd ~/.claude
./sync-claude-config.sh pull
```

### Check What Changed
```bash
cd ~/.claude
./sync-claude-config.sh diff
```

---

## Setup on a New Host (Complete)

### Fastest Method (Automated)
```bash
bash <(curl -fsSL https://raw.githubusercontent.com/proton-pidgeon/claude-code-config/main/bootstrap-claude-config.sh) -r "https://github.com/proton-pidgeon/claude-code-config.git"
```

### Manual Method
```bash
cd ~
git clone https://github.com/proton-pidgeon/claude-code-config.git .claude
cp ~/.claude/settings.local.template.json ~/.claude/settings.local.json
claude auth login
```

---

## What Gets Synced

✅ **Configuration** (synced everywhere)
- `settings.json` - Global settings, permissions, plugins
- `history.jsonl` - Conversation history
- `agents/` - Your custom agents
- `skills/` - Your custom skills
- `commands/` - Your custom commands
- Plugin manifests

❌ **NOT Synced** (host-specific or sensitive)
- `.credentials.json` - OAuth tokens (local only)
- `settings.local.json` - Host-specific permissions
- `projects/` - Large session data
- `plugins/cache/` - Auto-regenerated
- `cache/`, `debug/`, `telemetry/` - Generated files

---

## Common Workflows

### I'm Done Working on Host A
```bash
cd ~/.claude
./sync-claude-config.sh push "Work session: added new agent"
```

### I'm Starting Work on Host B
```bash
cd ~/.claude
./sync-claude-config.sh pull
```

### I Changed Settings on Both Hosts (conflict)
```bash
cd ~/.claude
./sync-claude-config.sh pull
# Manually merge settings.json if needed
cat settings.json settings.local.json > temp.json
# Edit and save as settings.json
git add settings.json
./sync-claude-config.sh push "Merge: combined settings from both hosts"
```

---

## Security Verification

### Verify Credentials Are Secure
```bash
cd ~/.claude
git check-ignore .credentials.json  # Should output: .credentials.json
git ls-files | grep -i credentials  # Should return nothing
```

### Verify Nothing Sensitive Is Staged
```bash
cd ~/.claude
git diff --cached --name-only | grep -i "cred\|token\|secret"  # Should return nothing
```

---

## Useful Git Commands

```bash
# See commit history
git log --oneline

# See what changed in last commit
git show HEAD

# Undo uncommitted changes
git checkout -- <file>

# View remote configuration
git remote -v

# Check current branch
git branch

# See repository size
du -sh .git
```

---

## Troubleshooting

### Forgot to Pull Before Changes
```bash
cd ~/.claude
git stash
./sync-claude-config.sh pull
git stash pop
```

### Need to See Latest Remote Changes
```bash
cd ~/.claude
git fetch origin
git diff origin/main
```

### History File Getting Too Large
See **SYNC-README.md** - "Handling Merge Conflicts" section

### Something Broke, Need to Reset
```bash
cd ~/.claude
git reset --hard origin/main
git clean -fd
```

---

## Full Documentation

For complete details, see: `~/.claude/SYNC-README.md`

---

## Support

All scripts are cross-platform (macOS, Linux, Windows with Git Bash/WSL):
- `bootstrap-claude-config.sh` - Setup on new hosts
- `sync-claude-config.sh` - Daily sync operations

Both scripts handle:
- HTTPS and SSH remotes
- Credential preservation
- Conflict detection
- Security validation

Questions? Check SYNC-README.md for detailed troubleshooting.
