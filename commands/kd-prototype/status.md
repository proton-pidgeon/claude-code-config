---
name: prototype:status
description: Display status of all prototype projects
category: workflows
complexity: low
---

# /prototype:status - View Prototype Status

Display the status and progress of all prototype workflows.

## Usage

```
/prototype:status
```

## What It Does

When you run `/prototype:status`, the command will:

1. **Scan for all prototypes**
   - Looks in `.claude/prototypes/*/state.json`
   - Finds all active prototypes

2. **Load each state file**
   - Reads project name, current stage, completion
   - Gets tech stack and progress metrics
   - Sorts by last updated (most recent first)

3. **Display summary**
   - Lists all prototypes with current progress
   - Shows completion percentage
   - Highlights any failures or issues

4. **Detail active prototype**
   - Shows detailed metrics for most recent
   - Progress details, files created, tests status

## Example Output

### With Multiple Prototypes

```
/prototype:status

Active Prototypes (3)
=====================

1. dashboard-app
   Stage: implementation (60% complete)
   Last updated: 2025-01-15 11:45 UTC
   Progress: 42/47 files created, 37/37 tests passing

   Tech Stack:
     Frontend: React + TypeScript
     Backend: Node.js + Express
     Testing: Jest + React Testing Library
     Styling: Tailwind CSS

   Completed Stages:
     ✅ ideation (2025-01-15 10:45)
     ✅ design (2025-01-15 11:00)

   Current Stage:
     ⏳ implementation (in progress)


2. cli-tool
   Stage: design (40% complete)
   Last updated: 2025-01-14 09:30 UTC
   Progress: Spec written, architecture designed

   Tech Stack:
     Language: Node.js/TypeScript
     Testing: Jest

   Completed Stages:
     ✅ ideation (2025-01-14 08:00)

   Current Stage:
     ⏳ design (in progress)


3. component-library
   Stage: testing (80% complete)
   Last updated: 2025-01-13 14:20 UTC
   Progress: 125 tests (all passing)

   Tech Stack:
     Frontend: React + TypeScript
     Testing: Jest + Storybook

   Completed Stages:
     ✅ ideation (2025-01-13 09:00)
     ✅ design (2025-01-13 10:30)
     ✅ implementation (2025-01-13 13:00)

   Current Stage:
     ⏳ testing (in progress)


Quick Commands:
  Resume most recent:     /prototype:resume
  Resume specific:        /prototype dashboard-app
  View detailed plan:     cat .claude/prototypes/dashboard-app/plan.md
  View implementation:    cd <worktree-path> && git log
```

### With No Prototypes

```
/prototype:status

No active prototypes found.

.claude/prototypes/ is empty.

To start a new prototype:
  /prototype my-app

Or see existing examples:
  /prototype --help
```

### With Single Prototype

```
/prototype:status

Active Prototypes (1)
====================

dashboard-app
  Stage: implementation (60%)
  Last updated: 2025-01-15 11:45 UTC

Project Spec:
  Real-time analytics dashboard for SaaS metrics
  Target: Web developers
  Key features: Data visualization, Customization, Export

Progress Metrics:
  Files created: 42
  Components: 12
  Tests written: 84
  Test coverage: 87%
  Git commits: 23

Stage Completion:
  ✅ Ideation (2025-01-15 10:45)
     - Requirements captured
     - Tech stack selected

  ✅ Design (2025-01-15 11:00)
     - Architecture designed
     - Implementation plan created
     - Worktree: /path/to/dashboard-app-worktree

  ⏳ Implementation (in progress since 2025-01-15 11:15)
     - Milestone 1: Setup ✅
     - Milestone 2: Core features 🟡 (in progress)
     - Milestone 3: API layer (pending)
     - Milestone 4: Frontend (pending)
     - Milestone 5: Polish (pending)

  ⚪ Testing (pending)
  ⚪ Deployment (pending)

Tech Stack:
  Frontend: React + TypeScript
  Backend: Node.js + Express
  Testing: Jest + React Testing Library
  Styling: Tailwind CSS

Decisions Made:
  Component-based architecture with React hooks
  RESTful API with Express
  PostgreSQL for data persistence

Recent Commits (last 5):
  - feat: Implement Dashboard component
  - test: Add Dashboard tests
  - feat: Connect to API
  - refactor: Simplify component logic
  - docs: Update README

To Resume: /prototype:resume
To View Details: cat .claude/prototypes/dashboard-app/state.json
```

## Understanding the Status Display

### Stage Completion

```
✅ Ideation    - Completed
🟡 Design      - In progress
⏳ Implementation - Queued (will run next)
⚪ Testing     - Pending (will run later)
⚪ Deployment  - Pending (will run at end)
```

### Progress Indicator

```
Stage: implementation (60% complete)
```

Calculation: `completed_stages / 5 * 100`

So:
- 0 completed = 0%
- 1 completed = 20%
- 2 completed = 40%
- 3 completed = 60%
- 4 completed = 80%
- 5 completed = 100%

### Metrics

**Files Created:** Total number of source code files written

**Components:** Reusable UI components (if applicable)

**Tests:** Total test count

**Coverage:** Code coverage percentage (target 80%+)

**Commits:** Number of git commits made

## Interpreting Results

### All Stages Complete ✅

```
Stage: complete (100%)
Completed Stages: 5/5
```

Your prototype is ready for deployment. Next steps:
- Review code in worktree
- Merge to main branch
- Follow DEPLOYMENT.md

### In Testing Stage 🟡

```
Stage: testing (80%)
Current Stage: testing
Tests: 82/84 passing (1 failure)
```

Issues to resolve:
- 2 failing tests - need to be fixed
- Security scan results - review findings
- Once tests pass, move to deployment

### In Implementation Stage 🟡

```
Stage: implementation (60%)
Completed: Ideation, Design
In Progress: Implementation
Milestones: 2/5 complete
```

Continue implementation:
- Run: `/prototype:resume`
- Completes milestone by milestone
- Tests ensure quality

## Commands to Manage Prototypes

### View Full Status
```
/prototype:status
```

### View Single Prototype
```
/prototype my-app
```

### Resume Most Recent
```
/prototype:resume
```

### Resume Specific
```
/prototype dashboard-app
```

### Start New
```
/prototype new-project
```

## Detailed State File

For deeper investigation, check the state.json file:

```bash
cat .claude/prototypes/my-app/state.json
```

Contains:
- Complete progress metrics
- All decisions made
- Artifact paths
- Test results
- Security findings

## Git History

To see implementation commits:

```bash
cd <worktree-path>
git log --oneline
```

To see detailed changes:

```bash
git diff main..HEAD
```

## File Structure

Each prototype has this structure:

```
.claude/prototypes/my-app/
├── state.json          # Current workflow state
├── spec.md             # Specification (from ideation)
└── plan.md             # Implementation plan (from design)
```

Plus git worktree contains:
```
my-app-worktree/
├── src/                # Implementation code
├── tests/              # Test suites
├── dist/               # Build artifacts
├── package.json
├── README.md
└── .git/               # Complete git history
```

## Troubleshooting

### State File Missing

```
/prototype:status

⚠️ Warning: State file not found for dashboard-app
  Expected: .claude/prototypes/dashboard-app/state.json
  Status: File missing

Worktree exists: /path/to/dashboard-app-worktree
Code preserved in worktree and git history.

To restart workflow:
  /prototype dashboard-app
```

### Worktree Missing

```
/prototype:status

⚠️ Warning: Worktree not found for dashboard-app
  Expected: /path/to/dashboard-app-worktree
  Status: Directory missing

State preserved: .claude/prototypes/dashboard-app/state.json

To recover:
  Option 1: /prototype dashboard-app (will recreate worktree)
  Option 2: git worktree repair (if in git repo)
```

## Status for Project Planning

Use status to:

1. **Track progress**
   - See which stage you're in
   - View completion percentage
   - Monitor test coverage

2. **Manage multiple projects**
   - See all prototypes at a glance
   - Prioritize by last updated
   - Switch between projects

3. **Debug issues**
   - Check test counts and failures
   - Review security findings
   - See if build succeeded

4. **Plan next session**
   - Know where to resume from
   - See completed work
   - Identify remaining tasks

## Tips

### Most Recent Project

The status command shows prototypes sorted by `last_updated`:

```
1. dashboard-app (2025-01-15 11:45)  ← Most recent
2. cli-tool (2025-01-14 09:30)
3. component-library (2025-01-13 14:20)
```

To resume most recent: `/prototype:resume`

### Check Specific Details

To view the full specification:
```bash
cat .claude/prototypes/my-app/spec.md
```

To view the implementation plan:
```bash
cat .claude/prototypes/my-app/plan.md
```

To view git history:
```bash
cd <worktree-path>
git log --stat
```

### Regular Check-ins

Run `/prototype:status` regularly to:
- Track progress
- Identify blockers early
- Plan next work session
- Monitor test health

### Export Status

To save status for sharing:
```bash
/prototype:status > status-report.txt
```

## Integration with Other Commands

### With Resume
```
/prototype:status       # See which to resume
/prototype:resume       # Resume most recent
```

### With Starting New
```
/prototype:status       # See existing projects
/prototype new-app      # Start new one
```

### With Git
```
/prototype:status       # Find worktree path
cd <worktree-path>
git log                 # See commits
```

---

## Implementation Notes

- Status is read-only - no modifications made
- Displays all prototypes found in `.claude/prototypes/`
- Sorted by `last_updated` (most recent first)
- Provides quick overview and detailed metrics
- Links to detailed documentation for each prototype
