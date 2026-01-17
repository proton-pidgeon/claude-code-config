---
name: prototype:resume
description: Resume the most recently worked-on prototype workflow
category: workflows
complexity: medium
---

# /prototype:resume - Resume Prototype Workflow

Resume the most recently worked-on prototype workflow from where it left off.

## Usage

```
/prototype:resume
```

## What It Does

When you run `/prototype:resume`, the command will:

1. **Find most recent prototype**
   - Scans all `.claude/prototypes/*/state.json` files
   - Finds the one with latest `last_updated` timestamp
   - Displays the project name and current progress

2. **Validate environment**
   - Checks if git worktree still exists
   - Verifies dependencies are installed
   - Confirms tests still pass
   - Logs any warnings but doesn't block

3. **Restore context** (if available)
   - Uses Serena MCP to restore conversation context
   - Searches episodic-memory for related decisions
   - Displays key decisions from previous sessions

4. **Display progress summary**
   ```
   Resuming: dashboard-app
   Completed stages: ideation, design
   Current stage: implementation
   Last updated: 2025-01-15 11:45 UTC
   Progress: 42 files created, 37 tests passing
   ```

5. **Continue from current stage**
   - Invokes the appropriate stage coordinator
   - Continues implementation/testing/etc. from where you left off
   - No duplicate work or lost progress

## Example

### Scenario 1: Resume Interrupted Implementation

You started `/prototype my-app` and worked through ideation and design. During implementation, you had to stop (perhaps Ctrl+C or session interrupted).

```
/prototype:resume
```

Output:
```
Resuming prototype workflow...

Project: my-app
Completed: ✅ ideation, ✅ design
Current: ⏳ implementation
Last updated: 2025-01-15 11:45 UTC

Progress:
  Files created: 42
  Tests passing: 37/37
  Security issues: 0

Git Worktree:
  Path: /Users/username/projects/my-app-worktree
  Status: ✓ Valid
  Commits: 23

Continuing from implementation stage...
```

The workflow automatically continues with the implementation stage.

### Scenario 2: Resume Failed Tests

You were in the testing stage and some tests failed. You fixed them locally.

```
/prototype:resume
```

Output:
```
Resuming prototype workflow...

Project: my-app
Completed: ✅ ideation, ✅ design, ✅ implementation
Current: ⏳ testing
Last updated: 2025-01-15 13:20 UTC

Resuming Testing Stage:
  - Previous test run had 2 failures
  - Running full test suite again...
  - Scanning code for security issues...
```

The testing stage runs again, and if all tests now pass, workflow continues.

### Scenario 3: Resume Multiple Days Later

You started a prototype days ago and want to continue.

```
/prototype:resume
```

Output:
```
Resuming prototype workflow...

Project: my-app
Completed: ✅ ideation, ✅ design
Current: ⏳ implementation
Last updated: 2025-01-10 15:45 UTC (5 days ago)

Previous Context:
  - Target users: Web developers
  - Key features: Component library, Theming
  - Tech stack: React + TypeScript, Node.js + Express
  - Architecture: Component-based with hooks

Git Worktree:
  Path: /Users/username/projects/my-app-worktree
  Commits: 23
  Status: ✓ Valid (no uncommitted changes)

Dependencies:
  Status: ✓ Installed
  Last check: 2025-01-10

Continuing from implementation stage...
```

The workflow shows you what was done before and continues from the current stage.

## How It Finds the Right Prototype

The resume command:

1. **Scans for state files**
   ```
   .claude/prototypes/*/state.json
   ```

2. **Sorts by timestamp**
   - Reads `last_updated` field from each state.json
   - Selects the most recent one

3. **Loads that project's state**
   - Reads complete state.json
   - Determines current_stage
   - Loads all decisions and progress so far

This way, you only need to run `/prototype:resume` without arguments, and it automatically finds the right project.

## What If Multiple Prototypes Exist?

If you have multiple prototypes in `.claude/prototypes/`:

```
.claude/prototypes/
├── my-app/
│   └── state.json (last updated: 2025-01-15 11:45)
├── dashboard/
│   └── state.json (last updated: 2025-01-14 09:30)
└── cli-tool/
    └── state.json (last updated: 2025-01-13 14:20)
```

Running `/prototype:resume` will **automatically resume my-app** (most recent).

### To Resume a Specific Project

If you want to resume a different project, start it explicitly:

```
/prototype dashboard
```

This will:
1. Check for existing state.json for "dashboard"
2. If found: resume from that state
3. If not found: start fresh workflow

## Environment Validation

When resuming, the command validates:

### ✅ Required (Must Be Present)
- State file exists and is readable
- Git worktree directory exists
- Git repo is valid

### ⚠️ Warnings (Continue But Log)
- Dependencies might be out-of-date: `npm install` may be needed
- Some test fixtures might be stale
- Worktree branch differs from expected

### ❌ Critical (Stop and Inform)
- State file corrupted (invalid JSON)
- Worktree deleted
- Git repo is corrupted

If critical issue found:
```
❌ Cannot Resume

The worktree for 'my-app' appears to have been deleted:
  Expected: /Users/username/projects/my-app-worktree
  Status: Not found

Options:
1. Create a new worktree:
   /prototype my-app

2. Manually restore:
   git worktree add ../my-app-worktree main

3. Investigate:
   Check if directory was moved or deleted
```

## Resumption Points

The workflow can resume from any stage:

**From Ideation:**
```
Project not yet designed.
Starting from ideation stage...
```

**From Design:**
```
Ideation complete. Spec ready.
Starting from design stage...
(Will create new git worktree)
```

**From Implementation:**
```
Ideation and design complete.
Continuing implementation...
(Uses existing worktree)
```

**From Testing:**
```
Implementation complete.
Running test suite...
(Tests may have failed, retrying)
```

**From Deployment:**
```
Tests passing. Finalizing deployment prep...
(Generating documentation, creating final commit)
```

## Auto-Context Restoration

When resuming, the command attempts to restore context:

### Via Episodic Memory
- Searches for decisions related to project name
- Displays previous ideation decisions
- Shows tech stack selections
- Recalls architecture decisions

Example:
```
Previous Decisions:
  Target users: Web developers
  Key features: Component library, Theming, Documentation
  Frontend: React + TypeScript
  Backend: Node.js + Express
  Testing: Jest + React Testing Library

You had decided on a component-based architecture with React hooks
and a RESTful API. Continuing with that approach...
```

### Via Serena (if available)
- Restores full conversation context from previous sessions
- Maintains decision history
- Links current session to previous work

## Troubleshooting

### State File Not Found

If you see:
```
❌ No active prototypes found

No state.json files in .claude/prototypes/
```

**Solutions:**
1. Check directory exists: `ls -la .claude/prototypes/`
2. Start a new prototype: `/prototype my-app`
3. Manually check project folder structure

### Worktree Missing

If you see:
```
⚠️ Warning: Worktree not found at:
  /Users/username/projects/my-app-worktree

The worktree may have been:
- Deleted manually
- Moved to different location
- Corrupted

Options:
1. Create new worktree: /prototype my-app
2. Restore from backup: git worktree repair
3. Manually recreate: git worktree add path main
```

**Solutions:**
1. Create new worktree in same location
2. Use `git worktree repair` to fix
3. Move worktree back to original location

### Corrupted State File

If you see:
```
❌ Error: State file corrupted or unreadable

Could not parse .claude/prototypes/my-app/state.json
Error: Unexpected token } in JSON

Options:
1. Check file manually: cat .claude/prototypes/my-app/state.json
2. Restore from backup if available
3. Start fresh: /prototype my-app
```

**Solutions:**
1. Manually fix JSON (remove trailing comma, etc.)
2. Restore from version control if available
3. Start new prototype (old work still in git worktree)

### Tests Still Failing

If you see during resumption of testing stage:
```
Resuming testing stage...
Running test suite...

❌ Tests Still Failing (2 failures)

Previous failures:
  - src/components/Form.test.tsx: validates email
  - tests/integration/api.test.ts: creates user

Options:
1. Fix code and resume: /prototype:resume
2. Debug in worktree: cd /path/to/worktree && npm test
3. Check recent commits: git log -5
```

**Solutions:**
1. Review code in worktree
2. Run tests locally to debug
3. Fix issues and run `/prototype:resume` again

## Tips

### Resume Frequently
- Don't try to complete prototype in one session
- Resume from staging when natural breaks occur
- Each stage has clear completion criteria

### Check Progress Often
```
/prototype:status
```
Shows all prototypes and their current progress.

### Review Git History
In the worktree:
```bash
git log --oneline
```
See all commits made so far.

### Check Current Stage
Look at state.json directly:
```bash
cat .claude/prototypes/my-app/state.json | grep current_stage
```

## What Doesn't Get Lost

When you resume, these persist:

✅ **Code** - All implementation work in git worktree
✅ **Tests** - All test code and results
✅ **Commits** - All git history preserved
✅ **Progress** - Metrics like files created, tests passing
✅ **Decisions** - All ideation and design decisions
✅ **Documentation** - Spec and plan documents

❌ **What Resets**

- Current session context (restored from episodic-memory if available)
- Build artifacts (`dist/` may need rebuild)
- npm cache (may need `npm install` again)
- Temporary files (removed by `npm clean`)

## Advanced: Force Resume Specific Project

If you have multiple prototypes and want to resume a specific one:

```
/prototype project-name
```

If state.json exists for that project:
- Resumes from saved state
- Continues from current_stage

If state.json doesn't exist:
- Starts fresh workflow for that project

## Examples

### Resume After Overnight Break
```
/prototype:resume
# Shows progress from last session
# Continues implementation
```

### Resume After Fixing Bugs Locally
```
# You edited code in the worktree locally
/prototype:resume
# Re-runs tests with your fixes
# If tests pass, continues to next stage
```

### Resume Multiple Projects
```
/prototype:status
# Shows all prototypes

/prototype:resume
# Resumes most recent (my-app)

/prototype my-other-project
# Or explicitly switch to different project
```

---

## Implementation Notes

- Resume is automatic resumption from where you left off
- No duplicate work - continues from current_stage
- All context restored from episodic-memory
- Validates environment before continuing
- Clear error messages if issues detected
- User can always start fresh with `/prototype project-name`
