---
name: prototype:state-manager
description: State save/load/resume logic for prototype workflow checkpointing
---

# State Manager - Prototype Workflow

## Overview

Handles all state persistence operations for the prototype workflow:
- Initialize new state
- Load existing state
- Save checkpoints after each stage
- Detect and resume incomplete workflows
- Format progress summaries

## State File Location

All state files are stored at:
```
.claude/prototypes/<project-name>/state.json
```

Each project has exactly one active state file.

---

## Initialize New State

**When:** Starting a new prototype workflow

**Function:** `initializeState(projectName)`

**Input:**
- `projectName`: Name of project (e.g., "my-app")

**Output:**
```json
{
  "version": "1.0",
  "project_name": "my-app",
  "created_at": "2025-01-15T10:30:00.000Z",
  "last_updated": "2025-01-15T10:30:00.000Z",
  "current_stage": "ideation",
  "completed_stages": [],
  "tech_stack": {
    "frontend": null,
    "backend": null,
    "testing": null,
    "styling": null
  },
  "decisions": {
    "ideation": {},
    "design": {}
  },
  "artifacts": {
    "spec": null,
    "plan": null,
    "worktree": null
  },
  "progress": {
    "files_created": 0,
    "tests_passing": 0,
    "tests_failing": 0,
    "security_issues": []
  }
}
```

**Actions:**
1. Create `.claude/prototypes/<project-name>/` directory if missing
2. Return initialized state object (don't save yet—save after ideation completes)

---

## Load Existing State

**When:** Resuming workflow or checking status

**Function:** `loadState(projectName)`

**Input:**
- `projectName`: Name of project

**Output:**
- State object from state.json
- OR null if file doesn't exist

**Actions:**
1. Check if `.claude/prototypes/<project-name>/state.json` exists
2. If exists: parse and return JSON object
3. If missing: return null (new workflow)
4. Validate state schema (warn if version mismatch)

**Error Handling:**
- If JSON parse fails: display error, suggest manual fix
- If directory missing: create it for new workflow

---

## Save Checkpoint

**When:** After each stage completes successfully

**Function:** `saveCheckpoint(state, stageCompleted)`

**Input:**
- `state`: Current state object (updated by stage coordinator)
- `stageCompleted`: Stage that just finished ("ideation", "design", etc.)

**Actions:**
1. Update `state.last_updated` to current ISO8601 timestamp
2. Add `stageCompleted` to `state.completed_stages` array (if not already present)
3. Advance `state.current_stage` to next stage:
   - ideation → design
   - design → implementation
   - implementation → testing
   - testing → deployment
   - deployment → (workflow complete)
4. Write state to `.claude/prototypes/<project-name>/state.json`
5. Display: "✅ Stage complete. Checkpoint saved."

**Output:**
- Updated state.json written to disk
- Confirmation message displayed

**Error Handling:**
- If directory doesn't exist: create it
- If write fails: display error but don't crash (resume can retry)

---

## Detect and Resume

**When:** Running `/prototype:resume` or auto-detecting continuation

**Function:** `detectAndResume()`

**Output:**
```
{
  "found": true/false,
  "projectName": "string",
  "state": {...},
  "summary": "string"
}
```

**Actions:**
1. **Find Most Recent State**
   - Scan all `.claude/prototypes/*/state.json` files
   - Parse each state.json
   - Sort by `state.last_updated` (descending)
   - Select most recent

2. **Load Selected State**
   - Parse state.json completely
   - Check if workflow complete (`current_stage` is null or workflow finished)

3. **Validate Environment**
   - If `artifacts.worktree` exists: verify path is accessible
   - If `artifacts.spec` or `artifacts.plan` exist: verify readable
   - Log warnings (e.g., "Warning: worktree path not found, will recreate")
   - Don't block on warnings

4. **Generate Summary**
   ```
   Resuming: <project-name>
   Completed stages: ideation, design
   Current stage: implementation
   Last updated: 2025-01-15 11:45 UTC
   Progress: 42 files created, 37 tests passing
   ```

5. **Restore Context** (if available)
   - If Serena MCP available: call `serena.restoreContext(projectName)`
   - Use episodic-memory to search for related decisions
   - Display key decisions from previous sessions

6. **Return Resume Info**
   ```json
   {
     "found": true,
     "projectName": "my-app",
     "state": {...full state object...},
     "summary": "Resuming my-app. Completed: ideation, design. Continuing from: implementation"
   }
   ```

**Error Handling:**
- If no state files found: return `{"found": false}`
- If state.json corrupted: display error, suggest manual inspection
- If environment validation fails: warn but continue (can recreate artifacts)

---

## Format Progress Summary

**When:** Displaying workflow status

**Function:** `formatProgressSummary(state)`

**Input:**
- `state`: Current workflow state

**Output:**
```
my-app Prototype - Status Report
================================
Created: 2025-01-15 10:30 UTC
Last updated: 2025-01-15 11:45 UTC

Stages Completed: 2/5 (40%)
  ✅ ideation (2025-01-15 10:45)
  ✅ design (2025-01-15 11:00)
  ⏳ implementation (in progress)
  ⚪ testing (pending)
  ⚪ deployment (pending)

Tech Stack:
  Frontend: React + TypeScript
  Backend: Node.js + Express
  Testing: Jest + React Testing Library
  Styling: Tailwind CSS

Progress Metrics:
  Files created: 42
  Tests passing: 37/37
  Tests failing: 0
  Security issues: 0

Artifacts:
  Spec: .claude/prototypes/my-app/spec.md
  Plan: .claude/prototypes/my-app/plan.md
  Worktree: /path/to/worktree/my-app

Key Decisions:
  [Ideation] Target: Web developers, Key features: [...], Tech stack: [...]
  [Design] Architecture: Component-based, File structure: src/{components, hooks, utils}
```

**Actions:**
1. Calculate completion % (`completed_stages.length / 5 * 100`)
2. Format timestamps in human-readable format
3. List tech stack from state.tech_stack
4. Display progress metrics from state.progress
5. Show completed stages with checkmarks
6. Show pending stages with circles
7. Show current stage with hourglass
8. List key decisions from ideation and design

---

## Update Progress

**When:** During implementation and testing stages

**Function:** `updateProgress(state, updates)`

**Input:**
- `state`: Current state object
- `updates`: Object with progress updates
  ```json
  {
    "files_created": 50,
    "tests_passing": 40,
    "tests_failing": 2,
    "security_issues": [
      { "type": "XSS", "severity": "medium", "location": "src/components/Form.tsx:42" }
    ]
  }
  ```

**Actions:**
1. Merge updates into `state.progress`
2. Update `state.last_updated` to current timestamp
3. Write state.json (checkpoint, not full save)
4. Display progress indicator if appropriate

**Output:**
- Updated state.json on disk

---

## Schema Validation

**Function:** `validateStateSchema(state)`

**Checks:**
1. Required fields present: version, project_name, created_at, last_updated, current_stage
2. Version matches expected (e.g., "1.0")
3. Stage values are valid: ideation, design, implementation, testing, deployment, null
4. Completed stages array contains only valid stages
5. Tech stack object has expected keys
6. Progress metrics are non-negative integers
7. Artifacts paths are strings or null

**Actions:**
- If valid: continue
- If invalid: log warning, suggest inspection
- Don't crash on schema errors (can be fixed manually)

---

## Workflow Completion

**When:** All stages finished successfully

**Function:** `completeWorkflow(state)`

**Input:**
- `state`: Final state after deployment prep completes

**Actions:**
1. Set `state.current_stage = null`
2. Ensure all 5 stages in `state.completed_stages`
3. Save checkpoint
4. Display completion message:
   ```
   🎉 Prototype Complete!

   Project: my-app
   Duration: Started 2025-01-15 10:30, Finished 2025-01-15 15:45

   ✅ All stages completed successfully

   Next Steps:
   - Code is in worktree: /path/to/worktree
   - Tests passing: 37/37
   - Security scan complete: 0 issues
   - Build artifacts ready for deployment

   To deploy:
   1. Review code in worktree
   2. Merge worktree to main branch
   3. Deploy using your standard process

   To start another prototype:
     /prototype <project-name>
   ```

**Output:**
- Final state.json with current_stage = null
- Completion message displayed

---

## Directory Structure

State manager maintains this structure:

```
.claude/
├── prototypes/
│   ├── project-1/
│   │   ├── state.json           # Single state file per project
│   │   ├── spec.md              # Written during ideation
│   │   └── plan.md              # Written during design
│   ├── project-2/
│   │   ├── state.json
│   │   ├── spec.md
│   │   └── plan.md
│   └── ...
```

**Notes:**
- One state.json per project (not per session)
- Spec and plan are generated by stage coordinators
- Worktree is external (path stored in state.artifacts.worktree)

---

## State Transitions

```
[Initialize] → [Load/Create state] → [Ideation] → [Save]
     ↓
[Design] → [Save]
     ↓
[Implementation] → [Save]
     ↓
[Testing] → [Save]
     ↓
[Deployment] → [Save]
     ↓
[Complete]

[Resume] → [Load state] → [Detect current stage] → [Continue from stage]
```

---

## Backward Compatibility

If state.json version differs from current:
1. Log warning: "State file version X.Y, expected 1.0"
2. Attempt to load anyway
3. If loading fails: stop and ask user to inspect manually
4. If loading succeeds: continue (field additions handled gracefully)

This allows future schema evolution without breaking existing workflows.

---

## Implementation Considerations

- Use ISO8601 timestamps everywhere (timezone-aware)
- Write state atomically (write to temp file, then rename)
- Don't fail workflow on state save errors (log and continue)
- Keep state file size reasonable (no mega-files)
- Document any state.json version bumps in skill description
