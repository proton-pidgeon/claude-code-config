---
name: prototype:stage-implementation
description: Implementation stage coordinator - builds code using TDD with code review
---

# Stage Implementation - Prototype Workflow

## Overview

The implementation stage executes the plan step-by-step using test-driven development (TDD). It writes tests first, implements code, reviews work, and makes atomic commits. Work happens in the isolated git worktree.

## Stage Input/Output Contract

**Input:**
- `project_name`: Name of project
- `state`: Current workflow state (with plan complete)
- `worktree_path`: Path to git worktree
- `plan_path`: Path to implementation plan

**Output:**
- `success`: Boolean (true if stage completes)
- `updated_state`: State with updated progress metrics
- `code_path`: Path to worktree with implementation

**Flow:**
1. Change to worktree directory
2. For each milestone:
   a. Invoke test-driven-development skill
   b. Invoke senior-dev agents for parallel implementation
   c. Between milestones: invoke code-reviewer
   d. Make atomic commits
3. Update progress metrics
4. Update and return state

---

## Step 1: Setup Worktree

**Action:**
```bash
cd <worktree_path>
# Verify we're in the right place
pwd
git status
```

**Verification:**
- Git repo exists
- Current branch is main or feature branch
- Working directory clean

If not clean:
```bash
# Stash any uncommitted changes
git stash
```

---

## Step 2: Initialize Project

**Purpose:** Set up project structure and install dependencies

**Actions:**

1. **Create Project Structure** (from plan file structure)
   ```bash
   mkdir -p src/components src/hooks src/utils src/styles
   mkdir -p tests/unit tests/integration tests/fixtures
   mkdir -p public
   ```

2. **Create Configuration Files**
   - `package.json` - Dependencies, scripts
   - `tsconfig.json` - TypeScript configuration
   - `.gitignore` - Exclude node_modules, build artifacts
   - `jest.config.js` - Testing configuration
   - `.env.example` - Environment variables template

3. **Install Dependencies**
   ```bash
   npm install
   ```

4. **Create Initial Commit**
   ```bash
   git add .
   git commit -m "Initial project setup"
   ```

**Verification:**
```bash
npm run build    # Should succeed
npm test         # Should run (with 0 tests)
```

---

## Step 3: TDD Cycle - Milestone by Milestone

**Pattern for Each Milestone:**

### Phase A: RED (Write Failing Tests)

**Action:**
```
Invoke superpowers:test-driven-development with:
  - Milestone description (from plan)
  - Feature requirements
  - Test type: unit, integration, or both
```

**TDD Skill Writes:**
- Failing tests for the feature
- Test fixtures/mocks as needed
- Clear test descriptions explaining requirements

**Output:**
```bash
npm test
# Tests fail (RED phase)
# FAIL  src/components/Header.test.tsx
#   ✗ renders title correctly
#   ✗ renders navigation menu
```

**Commit Failing Tests:**
```bash
git add tests/
git commit -m "RED: Write tests for Header component"
```

### Phase B: GREEN (Write Code to Pass Tests)

**Action:**

For simple features (< 100 lines):
```
Implement code directly in session:
  1. Write code to pass tests
  2. Run tests: npm test
  3. Verify passing
```

For complex features (> 100 lines):
```
Dispatch parallel senior-dev agents:
  - Break feature into sub-tasks
  - Assign to multiple agents
  - Agents implement in parallel
  - Integrate results
```

Example parallel dispatch:
```
Senior-Dev Agent 1:
  - Implement Header component
  - Tests should pass

Senior-Dev Agent 2:
  - Implement Navigation component
  - Tests should pass

Senior-Dev Agent 3:
  - Implement routing logic
  - Tests should pass

[Wait for all to complete, then integrate]
```

**Output:**
```bash
npm test
# All tests pass (GREEN phase)
# PASS  src/components/Header.test.tsx
#   ✓ renders title correctly
#   ✓ renders navigation menu
```

**Commit Implementation:**
```bash
git add src/
git commit -m "GREEN: Implement Header component to pass tests"
```

### Phase C: REFACTOR (Improve Code)

**Action:**

Between milestones, invoke code-reviewer:
```
Invoke superpowers:code-reviewer with:
  - Recent commits/files
  - Codebase context
  - Focus: readability, maintainability, patterns
```

**Code Reviewer Analyzes:**
- Code clarity and naming
- DRY principle violations
- Pattern consistency
- Performance issues
- Test coverage gaps

**Refactoring Actions:**
- Simplify complex logic
- Extract helper functions
- Remove duplicated code
- Improve test coverage
- Add clarifying comments (only where needed)

**Commit Refactoring:**
```bash
git commit -m "REFACTOR: Simplify Header component logic"
```

**Output:**
```bash
npm test
# All tests still pass (REFACTOR phase)
# Code is cleaner and more maintainable
```

---

## Step 4: Milestone Execution Loop

**For Each Milestone (from plan):**

1. **Display Milestone Start**
   ```
   Milestone 1: Project Setup
   - Create project structure
   - Install dependencies
   - Configure tooling
   ```

2. **RED Phase**
   - Invoke TDD skill
   - Write tests for all requirements
   - Commit tests

3. **GREEN Phase**
   - Implement code to pass tests
   - For complex features: dispatch parallel agents
   - Run tests: `npm test`
   - Commit implementation

4. **REFACTOR Phase** (after every 2-3 milestones)
   - Invoke code-reviewer
   - Improve code quality
   - Commit refactoring

5. **Display Milestone Complete**
   ```
   ✅ Milestone 1 Complete
   - All tests passing
   - Code committed
   - Ready for next milestone
   ```

6. **Update Progress**
   ```javascript
   state.progress.files_created += <files_in_this_milestone>
   ```

---

## Step 5: Code Review Checkpoints

**When to Trigger Code Review:**
- After every 2-3 milestones
- Before implementing complex features
- When unsure about architecture decision
- To validate adherence to plan

**Code Review Request:**
```
Invoke superpowers:code-reviewer with:
  - Commits since last review
  - Key files modified
  - Any architectural concerns
  - Test coverage data
```

**Code Review Feedback:**
- Architecture alignment
- Code quality issues
- Missing test coverage
- Security concerns
- Performance opportunities

**Actions on Feedback:**
1. **Critical Issues** (blocking)
   - Fix immediately
   - Add tests for fix
   - Re-review if major

2. **Improvements** (non-blocking)
   - Incorporate if time permits
   - Document decision if deferred
   - Note for polish phase

3. **Nice-to-Haves** (polish)
   - Consider for refactor phase
   - May skip if time-constrained

---

## Step 6: Atomic Commits

**Commit Strategy:**

Each commit should:
- Be logically complete (one feature or fix)
- Have tests passing
- Have clear message
- Be small enough to understand quickly

**Commit Message Format:**

```
<type>: <description>

<body - optional>

<footer - optional>
```

**Types:**
- `feat:` New feature
- `fix:` Bug fix
- `test:` Test addition or fix
- `refactor:` Code restructuring
- `perf:` Performance improvement
- `docs:` Documentation
- `style:` Formatting (no logic change)

**Examples:**

```
feat: Add Header component with navigation menu

- Renders title from props
- Displays navigation links
- Responsive design with Tailwind
- 100% test coverage

Tests: ✓ 6 passing
Coverage: 100%
```

```
refactor: Extract HeaderNav into separate component

Improves maintainability by splitting concerns.
HeaderNav now handles only menu logic.

Tests: ✓ 6 passing
Coverage: 100%
```

---

## Step 7: Parallel Implementation (For Complex Milestones)

**When to Parallelize:**
- Milestone has 3+ independent tasks
- Tasks have no shared dependencies
- Can safely implement in isolation

**Dispatch Pattern:**

```javascript
// Break milestone into independent tasks
const tasks = [
  {
    name: "Database Models",
    responsibility: "Define and implement User, Post, Comment models"
  },
  {
    name: "API Endpoints",
    responsibility: "Create REST endpoints for models"
  },
  {
    name: "Frontend Components",
    responsibility: "Build UI components for posts"
  }
];

// Dispatch agents in parallel
for (const task of tasks) {
  dispatchSeniorDevAgent({
    task: task.name,
    responsibility: task.responsibility,
    testFirst: true,  // TDD
    constraints: "Must pass all tests"
  });
}

// Wait for all to complete
await Promise.all(agents);

// Integrate results
integrateMilestoneWork();
```

**Coordination:**
- Each agent works in parallel
- All must pass tests before integration
- Integration happens in main session
- Commit integrated work

---

## Step 8: Update Progress Metrics

**During Implementation:**

After each milestone:
```javascript
state.progress.files_created += milestone_files;
```

Before moving to testing:
```javascript
state.progress.files_created = <total_files_in_worktree>;
```

Query for test metrics:
```bash
npm test -- --coverage
# Extract:
# - Total tests
# - Passing tests
# - Failing tests
# - Coverage %
```

---

## Step 9: Handle Implementation Blockers

**If Tests Fail Unexpectedly:**
1. Analyze failure message
2. Debug test expectations
3. Fix test or code
4. Re-run tests
5. Commit fix

**If Code Review Finds Critical Issues:**
1. Stop implementation
2. Fix critical issues
3. Re-run code review
4. Continue when cleared

**If Feature Too Complex:**
1. Break into smaller tasks
2. Implement sub-tasks first
3. Integrate together
4. Verify tests still pass

**If Architecture Needs Change:**
1. Discuss trade-offs
2. Update plan.md if major
3. Implement change
4. Add tests for change
5. Continue

---

## Step 10: Final Implementation Commit

**Before Moving to Testing:**

1. **Verify All Tests Pass**
   ```bash
   npm test
   # All tests passing
   ```

2. **Verify Build Succeeds**
   ```bash
   npm run build
   # Build succeeds with no errors
   ```

3. **Verify Code Quality**
   ```bash
   npm run lint  # if available
   # No blocking issues
   ```

4. **Final Commit**
   ```bash
   git commit -m "feat: Complete implementation of all milestones

   - Milestone 1: Setup and configuration
   - Milestone 2: Data models and database
   - Milestone 3: API layer
   - Milestone 4: Frontend components
   - Milestone 5: Polish and optimization

   All tests passing: X/X
   Coverage: X%
   Build: ✓ Succeeds"
   ```

5. **Check Repo Status**
   ```bash
   git log --oneline | head -20  # Recent commits
   git status  # Should be clean
   ```

---

## Step 11: Mark Complete

Stage coordinator returns control to main orchestration skill, which:
1. Saves state checkpoint with progress metrics
2. Marks implementation as completed
3. Advances current_stage to "testing"
4. Invokes stage-testing coordinator

---

## MCP Integration

### Context7 Framework Patterns (Optional)

If available, use for framework-specific patterns:
```
Query for:
  - React component patterns and conventions
  - Express middleware best practices
  - Testing patterns for framework
  - Common project structure
```

Use to:
- Validate file organization
- Check component implementation patterns
- Verify API endpoint structure

### Serena Context (Optional)

If available and resuming:
- Restore previous implementation context
- Continue from last completed milestone
- Reference previous decisions

---

## Error Handling

**If TDD Skill Fails:**
- Display error
- Return `{success: false}`
- State not updated, user can retry

**If Code Implementation Fails:**
- Display error details
- Ask if user wants to debug or abandon feature
- If debug: continue in same phase
- If abandon: revert commits and skip feature

**If Tests Fail:**
- Display test failures
- Don't continue until tests pass
- Fix code and re-run
- Commit fix

---

## Example Output

### Implementation Complete ✅

```
Implementation Stage: Complete

Project: dashboard-app

Milestones Completed: 5/5
  ✅ Milestone 1: Project Setup
  ✅ Milestone 2: Data Models
  ✅ Milestone 3: API Layer
  ✅ Milestone 4: Frontend Components
  ✅ Milestone 5: Polish & Optimization

Code Metrics:
  Files created: 47
  Components: 12
  Tests written: 84
  Test coverage: 87%
  Commits made: 23

Recent Commits:
  - feat: Complete implementation of all milestones
  - refactor: Simplify component logic
  - test: Add integration tests for API
  - feat: Implement user authentication
  - feat: Create Dashboard component

Build Status:
  ✓ npm run build succeeds
  ✓ npm test passes (84 tests)
  ✓ No lint errors

Ready for Testing Phase:
  - Code review complete
  - All tests passing
  - Build artifacts ready

Next: Testing phase will verify correctness and security
```

---

## Implementation Notes

- TDD is mandatory: RED-GREEN-REFACTOR cycle
- Keep commits small and atomic
- Code review every 2-3 milestones minimum
- Parallel agents for independent work only
- All tests must pass before moving to next milestone
- Build must succeed before moving to testing
- Document decisions in code/commits for future clarity
