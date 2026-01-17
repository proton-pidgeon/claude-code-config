---
name: prototype:stage-testing
description: Testing + security stage coordinator - runs tests and security scanning
---

# Stage Testing - Prototype Workflow

## Overview

The testing stage verifies the implementation is correct and secure. It runs full test suite, performs security scanning, and validates that all requirements are met before moving to deployment prep.

## Stage Input/Output Contract

**Input:**
- `project_name`: Name of project
- `state`: Current workflow state (with implementation complete)
- `worktree_path`: Path to git worktree with code
- `plan_path`: Path to implementation plan

**Output:**
- `success`: Boolean (true if all checks pass)
- `updated_state`: State with test results and security findings
- `test_report`: Summary of test results

**Flow:**
1. Change to worktree directory
2. Run full test suite (unit + integration)
3. Perform security scanning
4. Verify all requirements met
5. Update progress metrics
6. Return success/failure

---

## Step 1: Prepare Testing Environment

**Action:**
```bash
cd <worktree_path>
# Verify we're in the right place
pwd
git status

# Clean any test artifacts from previous runs
npm run test:clean  # if available
# OR
rm -rf coverage/
```

**Verification:**
- Git repo exists and is clean
- Dependencies installed (`node_modules/` exists)
- Configuration files present (jest.config.js, tsconfig.json, etc.)

---

## Step 2: Run Full Test Suite

**Purpose:** Verify all unit and integration tests pass

**Action:**
```bash
npm test -- --coverage --verbose
```

**Output Parsing:**
```
PASS  src/components/Header.test.tsx
PASS  src/hooks/useAuth.test.ts
PASS  tests/integration/api.test.ts
...

Test Suites: 12 passed, 12 total
Tests:       84 passed, 84 total
Snapshots:   0 passed, 0 total
Time:        12.345 s

Coverage Summary:
  Statements   : 87.5% ( 700/800 )
  Branches     : 82.3% ( 500/608 )
  Functions    : 88.1% ( 450/511 )
  Lines        : 87.9% ( 705/802 )
```

**Capture Metrics:**
```javascript
state.progress.tests_passing = 84;
state.progress.tests_failing = 0;
state.coverage = {
  statements: 87.5,
  branches: 82.3,
  functions: 88.1,
  lines: 87.9
};
```

**Handling Test Failures:**

If tests fail:
```
Display failed tests:
  FAIL  src/components/Form.test.tsx
    ✗ validates email correctly
    ✗ submits form data

Failure details:
  Expected: true
  Received: false
```

**Actions:**
1. Log all failures
2. Save state at testing stage (for resumption)
3. Return `{success: false, test_failures: [...]}"`
4. User can fix code and resume

---

## Step 3: Security Scanning

**Purpose:** Identify security vulnerabilities in code

**Action:**

Invoke `superpowers:security-expert` with:
```
Code location: <worktree_path>
Scope: Full codebase
Focus areas:
  - Authentication and authorization
  - Input validation
  - XSS prevention
  - SQL injection prevention
  - Secrets exposure
  - Dependency vulnerabilities
  - OWASP Top 10
```

**Security Expert Analysis:**
The agent will examine:
1. **Authentication/Authorization**
   - Are passwords hashed?
   - Are tokens validated?
   - Are routes protected?
   - Is session management secure?

2. **Input Validation**
   - Are user inputs validated?
   - Are forms sanitized?
   - Are API parameters checked?
   - Is data type validation present?

3. **Output Encoding**
   - Is output escaped for XSS prevention?
   - Are templates safe?
   - Is JSON parsing safe?

4. **Sensitive Data**
   - Are secrets committed?
   - Are passwords logged?
   - Are API keys exposed?
   - Is PII properly handled?

5. **Dependencies**
   - Are dependencies up-to-date?
   - Are there known vulnerabilities?
   - Is npm audit clean?

6. **Code Patterns**
   - SQL injection risks (if using raw SQL)
   - Command injection risks
   - Deserialization risks
   - Unsafe eval usage

**Capture Findings:**

```javascript
state.progress.security_issues = [
  {
    severity: "high",
    type: "XSS Vulnerability",
    location: "src/components/Comment.tsx:42",
    description: "User input rendered without escaping",
    remediation: "Use innerText instead of innerHTML"
  },
  {
    severity: "medium",
    type: "Missing Input Validation",
    location: "src/api/handlers.ts:15",
    description: "Email field not validated",
    remediation: "Add email regex validation"
  }
];
```

**Handling Security Issues:**

**Critical Issues** (must fix before deployment):
- SQL injection vulnerability
- Authentication bypass
- Secrets exposed in code
- XSS in user input areas
- Privilege escalation

**Medium Issues** (should fix):
- Missing input validation
- Weak password policies
- Missing HTTPS enforcement
- Logging sensitive data

**Low Issues** (nice-to-fix):
- Missing security headers
- Outdated dependencies (non-critical)
- Code patterns (not exploitable)

**Actions:**
1. Categorize by severity
2. Log all issues
3. If critical: mark testing failed, save state, return failure
4. If only medium/low: continue, report in summary

---

## Step 4: Dependency Vulnerability Check

**Purpose:** Identify vulnerable dependencies

**Action:**
```bash
npm audit
```

**Output Example:**
```
83 vulnerabilities found:
  72 moderate
  11 high

Remediation:
  Some vulnerabilities require manual review and acceptance of the risk.
  Run `npm audit` for details.
```

**Handling Vulnerabilities:**

1. **High Severity**
   - Must fix or update
   - If update available: update and re-test
   - If no fix: evaluate risk vs benefit

2. **Moderate Severity**
   - Review impact
   - Update if safe
   - Document if deferred

3. **Low Severity**
   - Log for awareness
   - Update when convenient

---

## Step 5: Verify Coverage Requirements

**Purpose:** Ensure sufficient test coverage

**Target:** 80%+ code coverage

**Action:**
```bash
# Test coverage already captured in npm test output
# Verify metrics meet target
```

**Coverage Thresholds:**
```javascript
const coverage = state.coverage;
const passes = coverage.lines >= 80;

if (!passes) {
  // Warning but not failure
  console.warn(`Coverage ${coverage.lines}% below 80% target`);
  // Continue - coverage can be improved later
}
```

**Handling Low Coverage:**
- If below 50%: likely missing major test suites
- If 50-80%: acceptable for prototype
- If above 80%: excellent coverage

---

## Step 6: Verify Build Process

**Purpose:** Ensure production build succeeds

**Action:**
```bash
npm run build
```

**Output Example:**
```
$ npm run build
> build
> typescript && vite build

vite v4.0.0 building for production...
✓ 2,341 modules transformed.
dist/index.html                   0.46 kB │ gzip:  0.32 kB
dist/assets/index.abc123.js     547.89 kB │ gzip: 142.33 kB
dist/assets/index.xyz789.css    12.34 kB │ gzip:  2.45 kB

✓ built in 12.34s
```

**Verification:**
- No errors in build output
- No TypeScript compilation errors
- Artifacts created in `dist/` or `build/` directory

**Handling Build Failures:**
- Display error details
- Save state at testing stage
- Return `{success: false, build_failure: true}`
- User can fix and resume

---

## Step 7: Run Code Quality Checks

**Purpose:** Verify code follows standards

**Action:**
```bash
# Lint check (if configured)
npm run lint

# Type check (if using TypeScript)
npm run type-check
```

**Handling Quality Issues:**

**Blocking:**
- Type errors
- Major lint violations

**Non-Blocking:**
- Style warnings
- Minor lint issues

If blocking: save state and return failure
If non-blocking: log and continue

---

## Step 8: Verification Before Completion

**Invoke** `superpowers:verification-before-completion` with:
```
Verification scope:
  - All tests passing (no failures)
  - No critical security issues
  - Build succeeds
  - Code quality checks pass
  - Coverage adequate (80%+)
  - Documentation complete
```

**Verification Checks:**
1. ✅ Unit tests: X/X passing
2. ✅ Integration tests: Y/Y passing
3. ✅ Security scan: Z critical issues (0 acceptable)
4. ✅ Build process: succeeds
5. ✅ Linting: passes
6. ✅ Type checking: passes
7. ✅ Coverage: X% (>= 80%)

**Actions on Verification:**
- If all pass: mark stage complete
- If failures: save state, return failure details

---

## Step 9: Generate Test Report

**Purpose:** Document testing results

**Format:**

```markdown
# Test Report: <Project Name>

## Executive Summary
- All tests passing: YES/NO
- Security issues: X
- Test coverage: Y%
- Build status: SUCCESS/FAILURE

## Test Results

### Unit Tests
- Total: 65
- Passed: 65
- Failed: 0
- Skipped: 0

### Integration Tests
- Total: 19
- Passed: 19
- Failed: 0
- Skipped: 0

## Coverage Report
```
Statements   : 87.5% ( 700/800 )
Branches     : 82.3% ( 500/608 )
Functions    : 88.1% ( 450/511 )
Lines        : 87.9% ( 705/802 )
```

## Security Scan Results

### Critical Issues: 0
✅ No critical vulnerabilities

### Medium Issues: 1
- Missing input validation in email field
  Location: src/api/handlers.ts:15
  Remediation: Add email regex validation

### Low Issues: 2
- Missing HSTS header
- Outdated dependency: lodash 4.17.15 → 4.17.21

## Build Verification
- Build command: `npm run build`
- Status: ✅ SUCCESS
- Output size: 547.89 KB (gzip: 142.33 KB)
- Time: 12.34s

## Code Quality
- Lint: ✅ PASS
- Type check: ✅ PASS
- No major issues

## Recommendations
1. Add input validation before deployment (medium priority)
2. Update lodash dependency (low priority)
3. Maintain 80%+ coverage in future updates

## Sign-off
✅ Ready for deployment prep phase
```

---

## Step 10: Update State

**State Changes:**

```javascript
state.progress = {
  files_created: 47,
  tests_passing: 84,
  tests_failing: 0,
  security_issues: [
    { severity: "medium", type: "Missing Input Validation", ... }
  ]
};

state.testing = {
  coverage: {
    statements: 87.5,
    branches: 82.3,
    functions: 88.1,
    lines: 87.9
  },
  test_suites_passed: 12,
  build_status: "success"
};
```

**Return to Orchestrator:**
```javascript
return {
  success: true,  // or false if tests/security/build fail
  updated_state: state,
  test_report: "path/to/test-report.md"
};
```

---

## Step 11: Handle Test Failures

**If Tests Fail:**

1. **Save State at Testing Stage**
   - Don't mark stage complete
   - Keep current_stage = "testing"
   - Save state to enable resumption

2. **Display Failures Clearly**
   ```
   ❌ Testing Stage Failed

   Failing Tests:
     - src/components/Form.test.tsx: validates email
     - tests/integration/api.test.ts: creates user

   Security Issues Found:
     - High: XSS in comment rendering
     - Medium: Missing CSRF protection

   Next Steps:
   1. Fix failing tests in worktree
   2. Address security issues
   3. Run: /prototype:resume
   4. Testing will retry from current state
   ```

3. **Return Failure**
   ```javascript
   return {
     success: false,
     failures: {
       tests: [...],
       security: [...]
     }
   };
   ```

4. **User Fixes Issues**
   - Edit code in worktree
   - Re-run tests locally to verify
   - Run `/prototype:resume`

5. **Resume Continues Testing**
   - Re-runs full test suite
   - Re-runs security scan
   - Verifies all now pass

---

## Step 12: Mark Complete

If all tests pass and security clean:

Stage coordinator returns control to main orchestration skill, which:
1. Saves state checkpoint with testing complete
2. Marks testing as completed
3. Advances current_stage to "deployment"
4. Invokes stage-deployment coordinator

---

## MCP Integration

### Security Expert Scanning (Integrated)

Automatically invoked in step 3. The security-expert agent provides:
- OWASP Top 10 analysis
- Authentication/authorization review
- Input validation assessment
- Dependency vulnerability scanning
- Secret detection
- Secure coding practices feedback

### Verification Skill (Integrated)

Automatically invoked in step 8. Confirms all requirements met:
- Tests passing
- Security acceptable
- Build successful
- Ready for deployment

---

## Error Handling

**Test Failures:**
- Save state at testing stage
- Return failure with details
- Resume will retry after fixes

**Security Issues (Critical):**
- Save state at testing stage
- Return failure with details
- User must fix before continuing

**Build Failure:**
- Save state at testing stage
- Return failure with build output
- User can fix and resume

**Security Expert Unavailable:**
- Continue with basic checks
- Log warning
- Recommend manual security review

---

## Example Output

### Testing Complete ✅

```
Testing Stage: Complete

Project: dashboard-app

Test Results:
  ✅ Unit Tests: 65/65 passing
  ✅ Integration Tests: 19/19 passing
  ✅ Total: 84/84 passing

Coverage:
  Statements: 87.5%
  Branches: 82.3%
  Functions: 88.1%
  Lines: 87.9%

Security Scan:
  ✅ No critical issues
  ⚠️ 1 medium issue (missing input validation)
  ℹ️ 2 low issues (headers, dependency updates)

Build Status:
  ✅ Production build succeeds
  Size: 547.89 KB (gzip: 142.33 KB)

Dependencies:
  ✅ npm audit clean (all high/critical addressed)

Code Quality:
  ✅ Linting passes
  ✅ Type checking passes

Ready for Deployment Prep:
  - All tests passing
  - No security blockers
  - Build verified
  - Documentation reviewed

Test report saved to:
  .claude/prototypes/dashboard-app/test-report.md

Next: Deployment prep will finalize artifacts and documentation
```

---

## Implementation Notes

- No test can be skipped; all must pass
- Security scan is mandatory and non-negotiable
- Coverage target is 80% minimum
- Build must succeed to proceed
- If anything fails: fix and resume (no skipping)
- Report all findings clearly
- Medium issues should be documented even if deferred
