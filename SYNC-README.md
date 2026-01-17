# Claude Code Configuration Sync

This directory uses Git to synchronize your Claude Code configuration across multiple hosts while keeping sensitive credentials secure.

## What Gets Synced

### ✅ Synced to All Hosts
- **settings.json** - Global settings, permissions, model preferences, enabled plugins
- **history.jsonl** - Conversation history for context restoration
- **agents/** - Custom agent definitions
- **skills/** - Custom skill definitions
- **commands/** - Custom command definitions
- **plugins/installed_plugins.json** - Plugin manifest with versions
- **plugins/known_marketplaces.json** - Marketplace registry
- **ide/** - IDE configuration files

### ❌ NOT Synced (Host-Specific or Sensitive)
- **.credentials.json** - OAuth tokens (preserved locally, never synced)
- **settings.local.json** - Host-specific permissions
- **plugins/cache/** - Downloaded plugins (auto-regenerated)
- **projects/** - Session data and projects (55MB+, host-specific)
- **plans/** - Large planning data
- **prototypes/** - Prototype session data
- **cache/**, **debug/**, **telemetry/** - Generated diagnostics
- **todos/** - Local to-do items
- **piper-voices/** - Large voice files

## Initial Setup on First Host

This is already done! The repository was initialized with:
```bash
cd ~/.claude
git init
git add -A
git commit -m "Initial commit: Claude Code configuration"
```

## Setup on a New Host

### Quick Bootstrap (Recommended)
```bash
# From your home directory
bash <(curl -fsSL https://raw.githubusercontent.com/YOUR_USERNAME/claude-code-config/main/bootstrap-claude-config.sh)
```

### Manual Setup
1. Clone the repository:
   ```bash
   cd ~
   git clone git@github.com:YOUR_USERNAME/claude-code-config.git .claude
   ```

2. Create host-specific settings:
   ```bash
   cp ~/.claude/settings.local.template.json ~/.claude/settings.local.json
   # Edit settings.local.json with host-specific permissions
   ```

3. Log in to Claude:
   ```bash
   claude auth login
   ```

4. Verify plugins are working:
   ```bash
   claude plugin list
   ```

## Daily Workflow

### Before Switching Hosts

Push your latest changes:
```bash
cd ~/.claude
./sync-claude-config.sh push "Update: installed new plugin"
```

Or if you want to review changes first:
```bash
./sync-claude-config.sh status
./sync-claude-config.sh diff
./sync-claude-config.sh push "Description of changes"
```

### After Switching Hosts

Pull the latest configuration:
```bash
cd ~/.claude
./sync-claude-config.sh pull
```

### Check Status Anytime
```bash
cd ~/.claude
./sync-claude-config.sh status
```

## Syncing Helpers

Quick reference for the `sync-claude-config.sh` script:

```bash
# Show current status
./sync-claude-config.sh status

# Show what changed
./sync-claude-config.sh diff

# Pull from remote
./sync-claude-config.sh pull

# Push to remote (requires commit message)
./sync-claude-config.sh push "Your commit message here"

# Check for uncommitted changes
./sync-claude-config.sh check
```

## Important: Credentials Security

### ⚠️ Critical Rules

1. **NEVER commit `.credentials.json`** to Git
2. **The .gitignore file protects this** - it's automatically excluded
3. **Each host manages its own credentials** via `claude auth login`
4. **Conversation history may contain sensitive information** - keep the repository PRIVATE

### Verifying Security
```bash
# Verify credentials file is excluded
git check-ignore .credentials.json
# Should output: .credentials.json

# Verify nothing credential-like is staged
git diff --cached --name-only | grep -i cred
# Should return nothing
```

## Handling Settings Conflicts

Both `settings.json` and `settings.local.json` are used for permissions:

- **settings.json** (synced): Global permissions shared across hosts
- **settings.local.json** (not synced): Host-specific permissions that override global

### Example: Adding a Permission
1. If it should work on all hosts: Add to `settings.json` and commit
2. If only on this host: Add to `settings.local.json` (not committed)

### Merging from Another Host
```bash
# Pull the latest
./sync-claude-config.sh pull

# Review combined permissions
cat settings.json
cat settings.local.json
```

## Troubleshooting

### Q: I forgot to pull before making changes
```bash
git stash
./sync-claude-config.sh pull
git stash pop
# Resolve any conflicts if they occur
```

### Q: I accidentally modified files on both hosts
```bash
# On the first host (with your intended changes)
cd ~/.claude
git add -A
git commit -m "Update: settings from host A"
git push

# On the second host
git pull
# Manually merge if needed, then:
git add -A
git commit -m "Merge: combined settings from both hosts"
git push
```

### Q: Conversation history is getting too large
If `history.jsonl` grows beyond 100MB:

**Option A: Use Git LFS**
```bash
git lfs install
git lfs track "history.jsonl"
git add .gitattributes
git commit -m "Add Git LFS for history"
git push
```

**Option B: Stop syncing history**
```bash
echo "history.jsonl" >> .gitignore
git rm --cached history.jsonl
git commit -m "Stop syncing history"
git push
```

### Q: Something broke, how do I restore?
```bash
# Reset to the last known good state
git reset --hard origin/main
git clean -fd
```

### Q: I see a merge conflict
```bash
# View conflicts
git status

# Edit the conflicting file manually
# Then resolve:
git add <file>
git commit -m "Resolve: merged conflicting permissions"
git push
```

## Repository Management

### GitHub Setup
- Repository name: `claude-code-config`
- Visibility: **PRIVATE** (required - contains conversation history)
- SSH access: Recommended for automated scripts

### Verifying Private Repo
```bash
# This should fail if the repo is truly private
curl -I https://github.com/YOUR_USERNAME/claude-code-config
```

## Best Practices

1. **Commit frequently** - After installing plugins, creating agents/skills, or changing global settings
2. **Use descriptive messages** - Makes it easier to track what changed
3. **Pull before switching hosts** - Prevents merge conflicts
4. **Review before push** - Always check `git diff` before committing
5. **Keep local settings minimal** - Use `settings.json` for shared config
6. **Never force push** - Unless absolutely necessary, and only to your own repo

## Advanced: Using Git Worktrees (Optional)

For parallel work on different features:
```bash
# Create a worktree for experimental config
git worktree add ~/.claude-experimental experimental-branch

# Switch between versions
cd ~/.claude          # Main config
cd ~/.claude-experimental  # Experimental config
```

## References

- [Git Documentation](https://git-scm.com/doc)
- [GitHub SSH Setup](https://docs.github.com/en/authentication/connecting-to-github-with-ssh)
- [Git LFS Guide](https://git-lfs.github.com/)

## Support

For issues with this sync setup:
1. Check `git log` to see recent changes
2. Review `git diff` to see what changed
3. Use `git reflog` to recover deleted commits
4. See troubleshooting section above

---

**Last Updated**: 2026-01-17
**Repository**: `claude-code-config`
