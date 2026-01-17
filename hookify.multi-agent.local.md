# Hookify Rule: Multi-Agent Parallelization Preferences

## Meta
- **Name**: Multi-Agent Parallelization Context
- **Description**: Injects multi-agent and parallelization preferences into every Claude Code interaction
- **Trigger**: On every user message submission
- **Priority**: High (applies early in processing)

---

## Activation Rules

### When to Activate
- Every user message that involves work tasks
- Multi-step requests
- Feature implementation requests
- Debugging or investigation tasks
- Code review or analysis tasks

### Pattern Matching
- Matches: Any request involving 2+ independent tasks
- Matches: Requests asking for "implementation", "feature", "debug", "review", "analyze"
- Matches: Requests with multiple goals separated by "and", "also", "plus"

---

## Core Instruction Injection

When processing user requests, actively apply these preferences:

### 1. Always Consider Multi-Agent Approach

**When to use multi-agent execution:**
- Multiple independent tasks exist with no shared dependencies
- Different specialist agents suit different subtasks
- Tasks can execute in parallel without blocking

**Agent Types Available:**
- `Explore` - Fast codebase exploration, file discovery, pattern matching
- `senior-dev` - Feature implementation, coding, debugging
- `code-reviewer` - Code quality, best practices, standards
- `security-expert` - Security vulnerabilities, auth flows, input validation
- `arch-infrastructure-reviewer` - System design, scalability, infrastructure
- `integration-engineer` - API design, third-party integrations, webhooks
- `project-orchestrator` - Complex projects, coordination, workflow management
- `ux-design-reviewer` - UI/UX review, interaction patterns, accessibility
- `plan` - Architecture planning, design patterns, approach strategy

### 2. Aggressive Parallelization

**Batch independent operations:**
```
✓ DO: Read 5 files in one message with Glob/Read in parallel
✓ DO: Launch 3 specialist agents simultaneously for independent work
✓ DO: Run multiple searches in one message
✓ DO: Check multiple remotes/branches in parallel Bash calls
```

```
✗ DON'T: Read one file, wait for result, then read another
✗ DON'T: Launch agent, wait, then launch next agent
✗ DON'T: Sequential Bash calls when they're independent
```

### 3. Use TodoWrite for Complex Tasks

**When to create a task list:**
- Any task with 3+ steps
- Multi-phase implementations
- When tracking progress is important
- When breaking down large features

**Benefits:**
- Shows user progress in real-time
- Prevents forgotten steps
- Demonstrates thoroughness
- Helps with task prioritization

### 4. Sequence ONLY When Necessary

**Sequential execution required for:**
- Task depends on output of previous task
- File operations that must happen in order (e.g., `git add` before `git commit`)
- Previous task must complete before next starts

**Example - Sequential with reason:**
```
git add file.js && git commit -m "msg" && git push
// Must sequence: add→commit→push (dependencies)
```

**Example - Parallel (no dependencies):**
```
// All independent, batch in one message:
- Read file1.js
- Read file2.js
- Search for pattern in codebase
- Check git status
- All happen in parallel
```

### 5. Task Decomposition Template

For complex requests, immediately decompose into parallel subtasks:

**Given**: Complex feature request
**Breakdown**:
1. **Research phase** (parallel):
   - Explore existing code patterns
   - Search for similar implementations
   - Review related documentation

2. **Design phase** (parallel):
   - Plan architecture
   - Review requirements
   - Identify dependencies

3. **Implementation phase** (parallel):
   - Senior-dev: Write core logic
   - Tests: Write test suite simultaneously
   - Documentation: Update docs simultaneously

4. **Review phase** (parallel):
   - Code-reviewer: Quality check
   - Security-expert: Security analysis
   - Arch-reviewer: Design validation

---

## Practical Examples

### Example 1: Feature Implementation Request

**User says**: "Add user authentication with OAuth2"

**Your approach:**
```
✓ Launch multi-agent in parallel:
  - Task 1: Explore existing auth patterns in codebase
  - Task 2: Research OAuth2 best practices
  - Task 3: Plan architecture (design agent)

✓ Then in parallel:
  - Task 4: Implement OAuth2 flow (senior-dev)
  - Task 5: Write security tests (security-expert reviews)
  - Task 6: Create API documentation

✓ Finally in parallel:
  - Task 7: Code review (code-reviewer)
  - Task 8: Security audit (security-expert)
  - Task 9: Architecture validation (arch-reviewer)
```

### Example 2: Bug Investigation

**User says**: "Login form isn't submitting, I'm getting 500 error"

**Your approach:**
```
✓ In parallel, launch:
  - Task 1: Explore error handlers in codebase (Explore agent)
  - Task 2: Search for login endpoint implementation (Explore agent)
  - Task 3: Review error logs/stack traces (senior-dev)

✓ Once info gathered, in parallel:
  - Task 4: Debug root cause (senior-dev)
  - Task 5: Check security implications (security-expert)
  - Task 6: Verify fix approach (code-reviewer)
```

### Example 3: Code Review Task

**User says**: "Review my API implementation"

**Your approach:**
```
✓ In parallel:
  - Task 1: Code quality review (code-reviewer)
  - Task 2: Security analysis (security-expert)
  - Task 3: Architecture assessment (arch-reviewer)
  - Task 4: Integration check (integration-engineer)

✓ Consolidate findings
✓ Prioritize recommendations
```

---

## When to Ask for Clarification

If a request is ambiguous about parallelization:
- Multi-agent approach requires clarification: **Ask before proceeding**
- Task decomposition unclear: **Ask user to clarify dependencies**
- Agent selection uncertain: **Ask which specialists needed**

Example:
```
I see you need to implement feature A, fix bug B, and review code C.

Are these independent, or does the order matter?
Can I work on all three in parallel, or do they have dependencies?
Which aspects are most important?
```

---

## Implementation Notes

### Signal Multi-Agent Usage
When using multi-agent approach, clearly communicate:
```
I'll use multi-agent execution for this - launching 3 specialists in parallel:
- Agent 1: Research phase
- Agent 2: Design phase
- Agent 3: Initial implementation
```

### Show Parallelization
Make parallel operations visible:
```
I'm running these in parallel:
1. Read file1.js
2. Read file2.js
3. Search for patterns
4. Check git history
```

### Track Progress with TodoWrite
```
Using TodoWrite to track this 5-step feature implementation:
- [ ] Phase 1: Explore (in progress)
- [ ] Phase 2: Design
- [ ] Phase 3: Implement
- [ ] Phase 4: Test
- [ ] Phase 5: Review
```

---

## Override Conditions

### When NOT to parallelize
- **Security-critical changes**: May need sequential review
- **Destructive operations**: Force-push, hard reset, deletions
- **Data migrations**: Must be sequential and verified
- **User explicitly requests**: "Do this step by step"

### When NOT to use multi-agent
- **Simple tasks**: One-line fixes, small edits
- **Straightforward debugging**: Single clear issue
- **Quick questions**: Information lookup, no implementation

---

## Preferences Summary

| Aspect | Preference |
|--------|------------|
| Multi-Agent | ✓ Aggressive use |
| Parallelization | ✓ Default parallel, sequence only if needed |
| Task Tracking | ✓ Use TodoWrite for 3+ step tasks |
| Agent Decomposition | ✓ Route to specialists early |
| Communication | ✓ Show parallelization clearly |
| Verification | ✓ Run agents in parallel for reviews |

---

## Synced Across Hosts

This rule is synced to all hosts via Git repository:
- **Stored in**: `~/.claude/hookify.multi-agent.local.md`
- **Deployed**: Via bootstrap script on new hosts
- **Updated**: Commit changes to sync across hosts

Changes to this rule automatically sync to all new hosts after next bootstrap.

---

**Created**: 2026-01-17
**Synced Via**: https://github.com/proton-pidgeon/claude-code-config
