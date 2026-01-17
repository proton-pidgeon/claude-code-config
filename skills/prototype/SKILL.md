---
name: prototype
description: Core orchestration for rapid prototype workflow - manages state and stage execution
---

# Prototype Workflow - Core Orchestration

## Overview

This skill orchestrates the five-stage prototype workflow:
1. **Ideation** - Clarify requirements and tech stack
2. **Design** - Create implementation plan
3. **Implementation** - Write code with TDD
4. **Testing** - Run tests and security scans
5. **Deployment Prep** - Build and documentation

## State Management

All workflow state is persisted to:
```
.claude/prototypes/<project-name>/state.json
```

This enables resumption after interruptions.

## Orchestration Flow

### 1. Initialize or Load State

```
IF state file exists:
  - Load state.json
  - Analyze current_stage and completed_stages
  - Display resumption summary
ELSE:
  - Initialize new state
  - Set current_stage = "ideation"
  - Create .claude/prototypes/<project-name>/ directory
```

### 2. Execute Current Stage

Based on `state.current_stage`, invoke the appropriate stage coordinator:

- **ideation** → Invoke stage-ideation skill
- **design** → Invoke stage-design skill
- **implementation** → Invoke stage-implementation skill
- **testing** → Invoke stage-testing skill
- **deployment** → Invoke stage-deployment skill

### 3. Save Checkpoint

After stage completes successfully:
```
- Update state.last_updated = ISO8601 timestamp
- Add stage to completed_stages array
- Advance current_stage to next stage
- Write state.json
```

### 4. Continue to Next Stage

If workflow not complete:
```
- Stay in same session
- Invoke next stage coordinator
- Repeat from step 2
```

If workflow complete:
```
- Display success message
- Show final state summary
- Display next steps for deployment
```

### 5. Error Handling

If stage fails or is interrupted:
```
- Save state at failure point (without marking stage complete)
- Display error/interruption message
- Exit gracefully
- User can resume later with /prototype:resume
```

---

## Stage Coordinator Contracts

Each stage coordinator (stage-*.md) follows this contract:

**Input:**
- `project_name`: Name of project
- `state`: Current workflow state object
- `tech_stack`: Technology selections from ideation

**Output:**
- `success`: Boolean (true if stage completed)
- `updated_state`: Updated state object with stage-specific data
- `artifacts`: Paths to generated files (spec.md, plan.md, code, etc.)

**Behavior:**
- Coordinator is responsible for its own work
- Returns updated state to be saved
- On failure: throws error, state not saved (resumable)
- On success: state is saved, workflow continues

---

## State Schema Reference

```json
{
  "version": "1.0",
  "project_name": "string",
  "created_at": "ISO8601",
  "last_updated": "ISO8601",
  "current_stage": "ideation|design|implementation|testing|deployment",
  "completed_stages": ["string"],
  "tech_stack": {
    "frontend": "string",
    "backend": "string",
    "testing": "string",
    "styling": "string"
  },
  "decisions": {
    "ideation": {},
    "design": {}
  },
  "artifacts": {
    "spec": "path/to/spec.md",
    "plan": "path/to/plan.md",
    "worktree": "path/to/worktree"
  },
  "progress": {
    "files_created": 0,
    "tests_passing": 0,
    "tests_failing": 0,
    "security_issues": []
  }
}
```

---

## MCP Server Integration

Before each stage, check for available MCP servers:

```
- Serena: Cross-session context persistence
  Usage: Restore previous decisions and conversation context
  Graceful fallback: Continue without context

- Tavily: Web research capability
  Usage: Research tech stack options in ideation
  Graceful fallback: Use general knowledge

- Context7: Framework-specific patterns
  Usage: Get idiomatic patterns during design and implementation
  Graceful fallback: Use general patterns
```

Implementation pattern:
```javascript
// Check if MCP server available
if (mcp.isAvailable("serena")) {
  mcp.serena.restoreContext();
}

// Continue with stage regardless
executeStage(...);
```

---

## Resumption Logic

When user runs `/prototype:resume`:

1. **Find Most Recent State**
   - Scan `.claude/prototypes/*/state.json`
   - Sort by `last_updated` (descending)
   - Load most recent

2. **Validate Environment**
   - If artifacts exist: verify paths are accessible
   - If worktree exists: verify it's still valid
   - Log warnings but don't block (can be recreated)

3. **Display Summary**
   ```
   Resuming: <project-name>
   Completed: ideation, design
   Current: implementation
   Last updated: 2025-01-15 11:45
   ```

4. **Restore Context**
   - If Serena available: restore conversation context
   - Use episodic-memory to search related decisions
   - Display relevant context from previous session

5. **Continue Workflow**
   - Execute current stage (same as normal flow)
   - Workflow continues from stage 3 onwards

---

## Detailed Stage Execution

### Stage 1: Ideation

**Coordinator:** `stage-ideation`

**Process:**
1. Invoke brainstorming skill with project context
2. If Tavily available: research tech stack options
3. Capture decisions (frontend, backend, testing, styling)
4. Write spec.md with requirements
5. Update state with tech_stack and decisions.ideation
6. Mark completed

**Artifacts:**
- `.claude/prototypes/<project>/spec.md`

**State Updates:**
```json
{
  "tech_stack": { "frontend": "...", "backend": "...", ... },
  "decisions": { "ideation": { ... } }
}
```

### Stage 2: Design

**Coordinator:** `stage-design`

**Process:**
1. Invoke using-git-worktrees to create isolated workspace
2. Invoke writing-plans skill with spec + tech stack
3. If Context7 available: query framework patterns
4. Invoke arch-infrastructure-reviewer for validation
5. Write plan.md with implementation steps
6. Update state with artifacts and design decisions
7. Mark completed

**Artifacts:**
- `.claude/prototypes/<project>/plan.md`
- Git worktree at `state.artifacts.worktree`

**State Updates:**
```json
{
  "artifacts": { "plan": "...", "worktree": "..." },
  "decisions": { "design": { ... } }
}
```

### Stage 3: Implementation

**Coordinator:** `stage-implementation`

**Process:**
1. Invoke test-driven-development skill
2. If Context7 available: get idiomatic patterns
3. For parallel tasks: dispatch senior-dev agents
4. Between milestones: invoke code-reviewer agent
5. Make incremental commits
6. Update progress (files_created)
7. Mark completed

**Artifacts:**
- Working code in worktree
- Git commits with messages

**State Updates:**
```json
{
  "progress": { "files_created": N }
}
```

### Stage 4: Testing

**Coordinator:** `stage-testing`

**Process:**
1. Run full test suite (unit + integration)
2. Invoke security-expert to scan code
3. Invoke verification-before-completion
4. Update progress (tests_passing, tests_failing, security_issues)
5. If failures: save state and stop (resumable)
6. Mark completed

**Artifacts:**
- Test results
- Security scan report

**State Updates:**
```json
{
  "progress": {
    "tests_passing": N,
    "tests_failing": N,
    "security_issues": [...]
  }
}
```

### Stage 5: Deployment Prep

**Coordinator:** `stage-deployment`

**Process:**
1. Run build process
2. Verify artifacts created
3. Generate/update README
4. Final commit: "Ready for deployment"
5. Mark completed
6. Display success message

**Artifacts:**
- Build artifacts
- README.md

---

## Session Linking

Each stage runs in the same session for continuity. When stage completes:

```
- Current session continues to next stage
- State.json persists across stages
- No session switching needed
- User sees continuous progress
```

For multi-session workflows:
```
- Each /prototype:resume call starts fresh session
- Episodic-memory links decisions across sessions
- User can see full history of decisions
```

---

## Error Handling Strategy

**Critical Failures (Stop Workflow):**
- Tests fail during testing stage
- Build fails during deployment prep
- Worktree deleted/unavailable
- Required MCP server error (if critical)

**Non-Critical Issues (Continue):**
- Optional MCP server unavailable (graceful fallback)
- Documentation generation issue (can be done manually)
- Minor security warnings (report and continue)

**Recovery:**
```
If stage fails:
  - Display clear error message
  - Save state at failure point
  - User runs /prototype:resume after fixing issue
  - Workflow retries same stage
```

---

## Implementation Notes

- Keep orchestration logic in this skill
- Each stage coordinator handles its own details
- State file is single source of truth for resumption
- No session switching within workflow
- Graceful MCP server fallbacks (log, don't crash)
- Display progress clearly between stages
