# Prototype Workflow - Comprehensive Guide

## Overview

The Prototype Workflow is a complete end-to-end system for rapid prototyping in Claude Code. It orchestrates a five-stage workflow that takes your idea from initial concept through production-ready deployment.

**Single command:** `/prototype my-app` → Complete prototype with tests, security scan, documentation, and deployment instructions.

## Quick Start

### Start a New Prototype

```bash
/prototype my-awesome-app
```

This launches:
1. **Ideation** - Clarify requirements and select tech stack
2. **Design** - Create architecture and implementation plan
3. **Implementation** - Build code using test-driven development
4. **Testing** - Run tests and security scanning
5. **Deployment Prep** - Generate artifacts and documentation

### Resume Work Later

```bash
/prototype:resume
```

Automatically continues from where you left off.

### Check Progress

```bash
/prototype:status
```

View all prototypes and their current progress.

## The Five Stages

### 1️⃣ Ideation (Requirements & Tech Stack)

**Duration:** 15-30 minutes
**Output:** `spec.md` with requirements and tech decisions

The workflow:
1. Launches brainstorming to clarify your project
2. Researches tech stack options (via Tavily if available)
3. Captures key decisions (frontend, backend, testing, styling)
4. Generates a specification document

**You decide:**
- What the project does
- Who uses it
- What features are in MVP
- What tech stack to use

### 2️⃣ Design (Architecture & Planning)

**Duration:** 30-45 minutes
**Output:** `plan.md` with implementation roadmap

The workflow:
1. Creates an isolated git worktree
2. Designs the system architecture
3. Validates the design (via architecture reviewer)
4. Researches framework-specific patterns
5. Generates a detailed implementation plan

**You get:**
- Clear file structure
- Step-by-step milestones
- Validated architecture
- Framework best practices

### 3️⃣ Implementation (Code with TDD)

**Duration:** 4-8 hours (depending on complexity)
**Output:** Complete working code with tests

The workflow:
1. Sets up project structure and dependencies
2. For each milestone:
   - **RED:** Write failing tests
   - **GREEN:** Write code to pass tests
   - **REFACTOR:** Improve code quality
3. Reviews code between milestones
4. Makes atomic git commits
5. Updates progress metrics

**Key principle:** Tests are written first, always.

### 4️⃣ Testing (Verification & Security)

**Duration:** 30-60 minutes
**Output:** Full test report and security findings

The workflow:
1. Runs complete test suite (unit + integration)
2. Performs security scanning (via security expert)
3. Checks dependencies for vulnerabilities
4. Verifies build succeeds
5. Checks code quality and linting

**Requirements:**
- All tests must pass ✅
- No critical security issues ✅
- Build must succeed ✅
- Coverage target: 80%+

If anything fails, the workflow pauses. You fix the issues and resume.

### 5️⃣ Deployment Prep (Finalization)

**Duration:** 15-30 minutes
**Output:** Ready-to-deploy code and documentation

The workflow:
1. Verifies production build
2. Generates/updates README
3. Creates deployment guide
4. Generates security documentation
5. Creates final commit

**You get:**
- Complete documentation
- Deployment instructions
- Security summary
- Production artifacts

## File Structure

After running a prototype, you'll have:

```
.claude/
├── commands/
│   └── prototype/
│       ├── COMMAND.md       # Main /prototype command
│       ├── resume.md        # /prototype:resume command
│       └── status.md        # /prototype:status command
├── skills/
│   └── prototype/
│       ├── SKILL.md         # Core orchestration
│       ├── state-manager.md # State persistence
│       ├── stage-ideation.md
│       ├── stage-design.md
│       ├── stage-implementation.md
│       ├── stage-testing.md
│       ├── stage-deployment.md
│       └── README.md        # This file
└── prototypes/
    └── my-app/              # Your prototype
        ├── state.json       # Workflow state
        ├── spec.md          # Requirements
        ├── plan.md          # Implementation plan
        └── <worktree>/      # Complete git repo with code
```

## Commands Reference

### /prototype `<project-name>`

Start a new prototype or resume an existing one.

```bash
/prototype dashboard-app
```

**If new:** Starts from ideation
**If existing:** Resumes from last stage

### /prototype:resume

Resume the most recently worked-on prototype.

```bash
/prototype:resume
```

Automatically:
1. Finds most recent prototype
2. Validates environment
3. Restores context
4. Continues from current stage

### /prototype:status

Display status of all prototypes.

```bash
/prototype:status
```

Shows:
- List of all prototypes
- Current stage for each
- Progress metrics
- Last updated time

## How Resumption Works

You can interrupt a prototype at any time. When you resume:

1. **Find most recent** - Scans all state files
2. **Load state** - Reads complete workflow state
3. **Validate** - Checks if worktree and code are intact
4. **Restore context** - Uses episodic-memory for decisions
5. **Continue** - Resumes from current stage

**No duplicate work** - The workflow never repeats completed stages.

Example:

```
Day 1:
  /prototype my-app
  → Completes ideation and design
  → Starts implementation
  → [You stop after 2 hours]

Day 2:
  /prototype:resume
  → Finds my-app
  → Shows: "Completed: ideation, design. Continuing: implementation"
  → Resumes exactly where you left off
```

## Tech Stack Selection

During ideation, the workflow helps you choose:

**Frontend:**
- React + TypeScript (ecosystem, component reuse)
- Vue (simplicity)
- Svelte (performance)
- Angular (enterprise)
- Vanilla JS (minimal)

**Backend:**
- Node.js + Express (JavaScript ecosystem)
- Node.js + Next.js (full-stack React)
- Python + FastAPI (modern, fast)
- Python + Django (batteries included)
- Go (performance, simplicity)
- Rust (safety, performance)

**Testing:**
- Jest (JavaScript standard)
- Vitest (faster alternative)
- Pytest (Python standard)
- Built-in testing (Go, Rust)

**Styling:**
- Tailwind CSS (utility-first, popular)
- CSS-in-JS (styled-components, Emotion)
- SASS/SCSS (preprocessor)
- CSS Modules (scoped styles)

## Workflow State

The workflow maintains a `state.json` file that tracks:

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
  "decisions": { ... },
  "artifacts": { ... },
  "progress": { ... }
}
```

This enables:
- **Resumption** - Know exactly where you left off
- **Progress tracking** - Metrics like files created, tests passing
- **Decision history** - Why you chose certain tech
- **Artifact management** - Paths to generated files

## MCP Server Integration

The workflow automatically uses these MCP servers when available:

### Serena (Context Persistence)
- Restores conversation context across sessions
- Links decisions to current work
- Graceful fallback: Works without it

### Tavily (Web Research)
- Research tech stack options
- Find best practices
- Graceful fallback: Uses general knowledge

### Context7 (Framework Patterns)
- Get framework-specific conventions
- Design per framework best practices
- Graceful fallback: Uses general patterns

**All fallbacks are graceful** - the workflow works fine even if MCP servers aren't available.

## Test-Driven Development (TDD)

The implementation stage strictly follows TDD:

### RED Phase
- Write failing tests first
- Tests define the requirements
- Nothing is implemented yet

### GREEN Phase
- Write minimum code to pass tests
- All tests must pass
- Code is correct but may be ugly

### REFACTOR Phase
- Improve code quality
- Extract helpers, remove duplication
- All tests still pass

This cycle repeats for each milestone, ensuring:
- ✅ Code is well-tested
- ✅ Requirements are met
- ✅ Quality is maintained

## Security Scanning

The testing stage includes automatic security scanning:

**Checks for:**
- OWASP Top 10 vulnerabilities
- Authentication/authorization issues
- Input validation gaps
- XSS and injection vulnerabilities
- Exposed secrets or credentials
- Dependency vulnerabilities

**Outcomes:**
- **Critical** - Must fix before deployment
- **Medium** - Should fix before deployment
- **Low** - Good to fix but not blocking

All findings are documented in generated SECURITY.md.

## Code Review

Between milestones, the workflow invokes code review:

**Checks:**
- Architecture alignment with plan
- Code clarity and naming
- DRY principle violations
- Test coverage gaps
- Performance issues
- Security patterns

**Feedback:**
- Critical issues block progress
- Improvements are incorporated if time permits
- Nice-to-haves noted for later

## Generated Documentation

The workflow generates complete documentation:

**README.md**
- Setup instructions
- Project overview
- Tech stack
- Building and testing
- Troubleshooting

**DEPLOYMENT.md**
- Pre-deployment checklist
- Deployment steps
- Environment configuration
- Rollback plan

**SECURITY.md**
- Security scan results
- Issues found and remediation
- Security practices implemented
- Reporting process

**spec.md**
- Project requirements
- Features and constraints
- Target users
- Non-functional requirements

**plan.md**
- Architecture overview
- File structure
- Milestones and tasks
- Testing strategy
- Risk mitigation

## Artifact Management

After each stage, the workflow saves artifacts:

**Ideation:**
- `spec.md` - Specification document

**Design:**
- `plan.md` - Implementation plan
- Git worktree - Isolated workspace

**Implementation:**
- All source code
- Test files
- Git commits with clear messages

**Testing:**
- Test results
- Coverage report
- Security scan findings

**Deployment:**
- Production build artifacts
- Documentation (README, DEPLOYMENT, SECURITY)
- Final commit with all changes

## Troubleshooting

### State File Not Found

**Symptom:** `/prototype:resume` says no prototypes found

**Fix:**
1. Check directory: `ls -la .claude/prototypes/`
2. Start new prototype: `/prototype my-app`

### Worktree Missing

**Symptom:** Warning about worktree not found during resume

**Fix:**
1. Check path: `ls -la <expected-worktree-path>`
2. Create new worktree: `/prototype my-app` (fresh start)
3. Or restore: `git worktree repair`

### Tests Failing During Resume

**Symptom:** Testing stage shows failures when resuming

**Fix:**
1. Check code in worktree
2. Run tests locally: `npm test`
3. Fix issues and resume: `/prototype:resume`

### Build Fails

**Symptom:** Deployment prep shows build error

**Fix:**
1. Check build output for specific error
2. Fix issues in worktree
3. Run `npm run build` to verify
4. Resume: `/prototype:resume`

### Corrupted State File

**Symptom:** JSON parse error when resuming

**Fix:**
1. Check file: `cat .claude/prototypes/my-app/state.json`
2. Fix JSON syntax if corrupted
3. Or start fresh: `/prototype my-app` (code is safe in worktree)

## Best Practices

### 1. Complete One Stage Per Session

Each stage has natural completion points. Complete one stage then resume later:

```
Session 1: Ideation (15 min)
Session 2: Design (30 min)
Session 3: Implementation (4 hours)
Session 4: Testing (1 hour)
Session 5: Deployment (30 min)
```

### 2. Review Between Stages

Between stages, review the generated output:
- Does the spec match your vision?
- Is the plan detailed enough?
- Is the code quality acceptable?

### 3. Fix Failures Immediately

If tests fail or security issues found:
- Fix the issues right away
- Resume testing
- Don't skip to next stage

### 4. Commit Frequently

The implementation stage makes atomic commits. Review git history:

```bash
cd <worktree-path>
git log --oneline
```

### 5. Monitor Progress

Check status regularly:

```bash
/prototype:status
```

Helps you:
- Track completion
- Identify bottlenecks
- Plan next sessions

## Advanced Usage

### Multiple Prototypes

You can have multiple prototypes in progress:

```bash
/prototype prototype-1    # Start first
/prototype:resume         # Resumes most recent

/prototype prototype-2    # Start second
/prototype:resume         # Now resumes prototype-2

/prototype prototype-1    # Explicitly switch to first
```

### Git Integration

All code is in a git worktree with full history:

```bash
cd <worktree-path>
git log --stat            # See all commits
git diff main..HEAD       # See all changes
git stash                 # Stash changes (if needed)
git branch -a             # See all branches
```

### Manual Code Changes

You can edit code in the worktree manually between sessions:

```bash
cd <worktree-path>
# Edit files
npm test                  # Verify tests still pass
/prototype:resume         # Resume workflow
```

The workflow will run full test suite and continue if tests pass.

### Export State

The state.json contains complete project information:

```bash
cat .claude/prototypes/my-app/state.json | jq '.'
```

You can use this for:
- Sharing progress with team
- Documenting decisions
- Analyzing metrics

## Integration with Claude Code

The Prototype Workflow integrates with Claude Code features:

**Superpowers Skills:**
- brainstorming - Ideation stage
- writing-plans - Design stage
- test-driven-development - Implementation stage
- code-reviewer - Code review checkpoints
- security-expert - Security scanning
- arch-infrastructure-reviewer - Architecture validation
- verification-before-completion - Final verification

**Episodic Memory:**
- Restores context when resuming
- Links decisions across sessions
- Preserves conversation history

**MCP Servers:**
- Serena - Context persistence
- Tavily - Web research
- Context7 - Framework patterns

## Common Workflows

### Quick Prototype (MVP)

Goal: Get basic version working quickly

1. **Ideation** (15 min)
   - Define core features (3-5)
   - Pick simple tech stack

2. **Design** (30 min)
   - Simple architecture
   - 2-3 milestones

3. **Implementation** (6-8 hours)
   - Focus on MVP only
   - Skip polish

4. **Testing** (1 hour)
   - Ensure core features work
   - Security check

5. **Deployment** (30 min)
   - Generate docs
   - Ready for feedback

### Production-Quality Prototype

Goal: Create product-ready code

1. **Ideation** (30 min)
   - Detailed requirements
   - Performance targets

2. **Design** (1 hour)
   - Comprehensive architecture
   - Database design

3. **Implementation** (10-12 hours)
   - Complete feature set
   - Full testing
   - Code review

4. **Testing** (2 hours)
   - Thorough testing
   - Security hardening
   - Performance validation

5. **Deployment** (1 hour)
   - Complete documentation
   - Deployment automation

### Learning Project

Goal: Learn new framework or tech

1. **Ideation** (15 min)
   - Pick learning goal
   - Choose framework

2. **Design** (30 min)
   - Research framework patterns
   - Plan simple architecture

3. **Implementation** (4-6 hours)
   - Write framework code
   - Learn by doing

4. **Testing** (1 hour)
   - Framework testing patterns
   - Best practices

5. **Deployment** (30 min)
   - Deploy to see it live

## Limitations & Future Enhancements

**Current Limitations:**
- Single developer per prototype
- Requires local git worktree
- Manual deployment after workflow

**Planned Enhancements:**
- Collaborative workflows
- Remote worktree support
- Automated deployment integration
- Framework-specific templates
- Performance profiling
- Load testing

## Support & Help

### Get Help

```bash
/prototype --help
/prototype:resume --help
/prototype:status --help
```

### View Documentation

In the generated prototype:
- `spec.md` - What you're building
- `plan.md` - How you're building it
- `README.md` - How to use it

### Debug State

```bash
cat .claude/prototypes/my-app/state.json
```

### Check Git History

```bash
cd <worktree-path>
git log -p
```

## Summary

The Prototype Workflow is designed to:

✅ **Take your idea** → Complete working prototype
✅ **Follow best practices** → TDD, security, code review
✅ **Generate documentation** → README, deployment guide, security docs
✅ **Support resumption** → Never lose progress
✅ **Track metrics** → Monitor progress objectively
✅ **Enable rapid iteration** → 5-stage workflow in one command

Whether you need a quick MVP or production-ready code, the Prototype Workflow provides structure, best practices, and complete documentation for your next project.

---

**Ready to start?**

```bash
/prototype my-awesome-app
```

Happy prototyping! 🚀
