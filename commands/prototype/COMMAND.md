---
name: prototype
description: Rapid end-to-end prototype workflow - from ideation through deployment prep
category: workflows
complexity: high
---

# /prototype - Rapid Prototype Workflow

Launch a complete end-to-end workflow for rapid prototyping: ideation → design → implementation → testing → deployment prep.

## Usage

```
/prototype <project-name>
/prototype:resume
/prototype:status
```

## Commands

### `/prototype <project-name>`
Start a new prototype workflow or resume an existing one.

**Arguments:**
- `project-name`: Name of the project (e.g., `my-test-app`, `user-dashboard`)

**What happens:**
1. Checks for existing state file in `.claude/prototypes/<project-name>/state.json`
2. If exists: auto-resumes from last incomplete stage
3. If new: initializes workflow and starts from ideation
4. Orchestrates all five workflow stages automatically

**Example:**
```
/prototype dashboard-app
```

### `/prototype:resume`
Resume the most recently worked-on prototype.

**What happens:**
1. Finds most recent state file (by `last_updated`)
2. Displays summary of completed stages
3. Validates environment (worktree exists, dependencies installed)
4. Restores conversation context if Serena MCP available
5. Continues from the last incomplete stage

**Example:**
```
/prototype:resume
```

### `/prototype:status`
Display status of all prototype projects.

**What happens:**
1. Lists all prototypes with state files
2. Shows: name, current stage, completion %, last updated
3. For active prototype: detailed progress metrics

**Example:**
```
/prototype:status
```

---

## How It Works

The workflow orchestrates five sequential stages:

1. **Ideation** - Clarify requirements, research tech stack, write specification
2. **Design** - Create architecture plan, validate with patterns, establish implementation strategy
3. **Implementation** - Write code using TDD, commit incrementally, review work
4. **Testing** - Run full test suite, perform security scanning, verify completeness
5. **Deployment Prep** - Build artifacts, verify deployability, generate documentation

### State Management

After each stage completes successfully, the workflow saves a checkpoint to:
```
.claude/prototypes/<project-name>/state.json
```

If interrupted (e.g., Ctrl+C), run `/prototype:resume` to continue from where you left off.

### Key Features

- **Auto-resumption**: Detects progress and continues seamlessly
- **Integrated security**: Security scanning in testing stage
- **MCP support**: Uses Serena (memory), Tavily (research), Context7 (patterns) when available
- **Graceful fallbacks**: Works without optional MCP servers
- **Artifact tracking**: Spec, plan, and implementation tracked in state

---

## Workflow Stages

### Stage 1: Ideation
- Launches brainstorming skill
- Researches tech stack options (via Tavily if available)
- Captures decisions: frontend, backend, testing, styling frameworks
- Outputs: `spec.md` with requirements and tech decisions

### Stage 2: Design
- Creates isolated git worktree for implementation
- Generates detailed implementation plan via writing-plans skill
- Validates architecture via arch-infrastructure-reviewer
- Incorporates framework patterns (Context7 if available)
- Outputs: `plan.md` with step-by-step implementation strategy

### Stage 3: Implementation
- Executes plan using test-driven development (RED-GREEN-REFACTOR)
- Writes tests first, then code
- Reviews work incrementally with code-reviewer agent
- Makes atomic commits with clear messages
- Outputs: Working code in isolated worktree

### Stage 4: Testing
- Runs full unit and integration test suite
- Scans code for security vulnerabilities (security-expert agent)
- Verifies all tests pass (verification-before-completion)
- Tracks test results and security findings
- Outputs: Test report and security scan results

### Stage 5: Deployment Prep
- Builds final artifacts
- Generates/updates README with setup instructions
- Creates final commit: "Ready for deployment"
- Outputs: Deployable artifacts and documentation

---

## State File Structure

After each stage, workflow saves state to `.claude/prototypes/<project-name>/state.json`:

```json
{
  "version": "1.0",
  "project_name": "my-app",
  "created_at": "2025-01-15T10:30:00Z",
  "last_updated": "2025-01-15T11:45:00Z",
  "current_stage": "implementation",
  "completed_stages": ["ideation", "design"],
  "tech_stack": {
    "frontend": "React + TypeScript",
    "backend": "Node.js + Express",
    "testing": "Jest + React Testing Library",
    "styling": "Tailwind CSS"
  },
  "decisions": {
    "ideation": {
      "target_users": "Web developers",
      "key_features": ["Component library", "Theming", "Documentation"]
    },
    "design": {
      "architecture": "Component-based with hooks",
      "file_structure": "src/{components,hooks,utils}"
    }
  },
  "artifacts": {
    "spec": ".claude/prototypes/my-app/spec.md",
    "plan": ".claude/prototypes/my-app/plan.md",
    "worktree": "/path/to/worktree"
  },
  "progress": {
    "files_created": 42,
    "tests_passing": 37,
    "tests_failing": 0,
    "security_issues": []
  }
}
```

---

## MCP Server Integration (Optional)

The workflow automatically uses these MCP servers if available:

### Serena (Context Persistence)
- Restores conversation context across sessions
- Links previous decisions to current work
- Graceful fallback: Works without it

### Tavily (Web Research)
- Research tech stack options during ideation
- Find best practices and patterns
- Graceful fallback: Skipped if unavailable

### Context7 (Framework Patterns)
- Get idiomatic code patterns for tech stack
- Design decisions based on framework conventions
- Graceful fallback: Uses general patterns

---

## Examples

### Start a new React app prototype
```
/prototype react-dashboard
```
- Ideation researches React best practices
- Design creates implementation plan
- Implementation builds with React + TypeScript
- Testing verifies functionality and security
- Deployment prep creates production build

### Resume interrupted work
```
/prototype:resume
```
If you started `react-dashboard` and got interrupted during implementation:
- Reads state.json
- Shows: "Resuming react-dashboard. Completed: ideation, design. Continuing from: implementation"
- Restores context
- Continues implementation from where you left off

### Check all prototypes
```
/prototype:status
```
Output:
```
Active Prototypes:
1. react-dashboard
   Stage: implementation (60% complete)
   Last updated: 2025-01-15 11:45
   Progress: 42 files created, 37/37 tests passing

2. cli-tool
   Stage: design (40% complete)
   Last updated: 2025-01-15 08:20
   Progress: Plan generated
```

---

## Troubleshooting

### State file not found
If `/prototype:resume` can't find a state file:
- Ensure `.claude/prototypes/<project-name>/` directory exists
- Check that `state.json` file is present
- Or start fresh: `/prototype <project-name>`

### Worktree missing after resume
If git worktree was deleted:
- Workflow detects this during resume validation
- Clear error message shown
- Option to create new worktree or abandon prototype

### Tests failing during testing stage
Workflow will:
1. Display test failures clearly
2. Save state at testing stage
3. Pause for manual fixes
4. `/prototype:resume` will retry testing after fixes

### Build failure during deployment prep
Workflow will:
1. Show build error output
2. Save state at deployment stage
3. Pause for manual fixes
4. `/prototype:resume` will retry build

---

## Next Steps After Workflow Completes

After successful completion:
- Code is in isolated git worktree
- All tests passing
- Security scanned
- Build artifacts created
- Documentation generated
- Ready for manual deployment

Merge worktree back to main branch manually or integrate into your deployment pipeline.
