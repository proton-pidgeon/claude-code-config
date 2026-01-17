---
name: prototype:stage-design
description: Design stage coordinator - creates implementation plan and architecture
---

# Stage Design - Prototype Workflow

## Overview

The design stage transforms the specification into a detailed implementation plan. It creates an isolated git worktree, designs the architecture, validates it, and produces a step-by-step implementation roadmap.

## Stage Input/Output Contract

**Input:**
- `project_name`: Name of project
- `state`: Current workflow state (with completed ideation)

**Output:**
- `success`: Boolean (true if stage completes)
- `updated_state`: State with populated plan and design decisions
- `plan_path`: Path to generated plan.md
- `worktree_path`: Path to git worktree

**Flow:**
1. Create isolated git worktree
2. Invoke writing-plans skill with spec + tech stack
3. Query framework patterns (Context7 if available)
4. Validate architecture (arch-infrastructure-reviewer)
5. Write plan.md
6. Update and return state

---

## Step 1: Create Isolated Git Worktree

**Purpose:** Create isolated workspace for implementation work

**Action:**

If current directory is git repo:
```bash
git worktree add ../<project-name>-worktree main
# This creates a new worktree based on main branch
```

If NOT git repo:
```bash
# Initialize a new repo for this prototype
cd .claude/prototypes/<project-name>/
git init
git config user.name "Prototype Workflow"
git config user.email "prototype@claude.local"
```

**Capture in State:**
```json
{
  "artifacts": {
    "worktree": "/absolute/path/to/project-name-worktree"
  }
}
```

**Actions:**
1. Verify git available
2. Create worktree or init repo
3. Log worktree path
4. Return path to next step

**Error Handling:**
- If git not available: warn and continue (can init later)
- If directory exists: use existing (resume case)
- If init fails: log error, ask user to create manually

---

## Step 2: Invoke Writing-Plans Skill

**Purpose:** Generate detailed implementation plan

**Action:**
```
Invoke superpowers:writing-plans with:
  - Specification (from state.artifacts.spec)
  - Tech stack (from state.tech_stack)
  - Project name
  - Target: Web application or CLI tool
  - Constraints from ideation
```

**Writing-Plans Skill Responsibility:**
- Analyze spec and tech stack
- Design system architecture
- Break implementation into milestones
- Create step-by-step implementation guide
- Identify critical files and dependencies
- Consider architectural trade-offs

**Capture From Plan:**
- Architecture overview
- Implementation milestones
- Key components/modules
- File structure
- Dependencies to install
- Build process
- Test strategy
- Deployment approach

---

## Step 3: Query Framework Patterns (Optional)

**Purpose:** Incorporate framework-specific best practices

**Action:**

If Context7 MCP available:
```
Query framework patterns for:
  1. Frontend framework conventions
     - Component structure
     - State management patterns
     - Routing approach
     - Testing patterns

  2. Backend framework conventions
     - Project structure
     - Request/response handling
     - Database access patterns
     - Error handling

  3. Full-stack patterns
     - API design
     - Authentication
     - Session management
```

If Context7 unavailable:
```
Use general best practices knowledge:
  - React: components, hooks, context, testing
  - Express: routers, middleware, error handling
  - Testing: AAA pattern, mocking, fixtures
  - Design: separation of concerns, modularity
```

**Integration:**
- Merge patterns into plan recommendations
- Update file structure to follow framework conventions
- Add framework-specific examples

---

## Step 4: Validate Architecture

**Action:**
```
Invoke superpowers:arch-infrastructure-reviewer with:
  - Implementation plan
  - Tech stack
  - Target users/load
  - Non-functional requirements from spec
```

**Reviewer Validates:**
- Database schema design (if applicable)
- API design and versioning
- Caching strategies
- Security considerations
- Scalability approach
- Monitoring/logging
- Deployment strategy

**Outcomes:**
1. ✅ Architecture is sound → continue
2. ⚠️ Warnings/improvements → incorporate into plan
3. ❌ Critical issues → revise and re-validate

**Capture Feedback:**
- Document any significant changes to plan
- Update state.decisions.design with validation feedback

---

## Step 5: Write Implementation Plan

**File:** `.claude/prototypes/<project-name>/plan.md`

**Content Structure:**

```markdown
# Implementation Plan: <Project Name>

## Architecture Overview

### High-Level Design
<Diagram or narrative of system architecture>

### Components/Modules
- Frontend Components: [list]
- Backend Services: [list]
- Database Models: [list]
- Utilities/Helpers: [list]

### Data Flow
<Description of how data flows through system>

### State Management
Frontend: [e.g., React Context, Redux]
Backend: [e.g., Express sessions]

## File Structure

```
project-root/
├── src/
│   ├── components/          # React components
│   │   ├── Header.tsx
│   │   ├── Dashboard.tsx
│   │   └── ...
│   ├── hooks/               # Custom React hooks
│   ├── utils/               # Utility functions
│   ├── styles/              # CSS/Tailwind
│   └── App.tsx
├── tests/
│   ├── unit/                # Unit tests
│   ├── integration/          # Integration tests
│   └── fixtures/            # Test data
├── public/                  # Static assets
├── package.json
├── tsconfig.json
└── README.md
```

## Dependencies

### Runtime Dependencies
```json
{
  "react": "^18.0",
  "react-dom": "^18.0",
  "express": "^4.18",
  "axios": "^1.0"
}
```

### Development Dependencies
```json
{
  "typescript": "^5.0",
  "jest": "^29.0",
  "@testing-library/react": "^14.0",
  "tailwindcss": "^3.0"
}
```

### Installation Steps
1. `npm install` - Install dependencies
2. `npm run build` - Build TypeScript
3. `npm test` - Run tests
4. `npm run dev` - Start development server

## Implementation Roadmap

### Milestone 1: Project Setup (Day 1)
- [ ] Initialize project structure
- [ ] Install dependencies
- [ ] Configure TypeScript
- [ ] Setup testing framework
- [ ] Create README

**Verification:**
- `npm run build` succeeds
- `npm test` runs without errors

### Milestone 2: Core Data Models (Day 2)
- [ ] Define database schema
- [ ] Create ORM models
- [ ] Write model tests
- [ ] Create fixtures

**Verification:**
- Database connects successfully
- Model tests pass

### Milestone 3: API Layer (Day 3)
- [ ] Define API routes
- [ ] Implement request handlers
- [ ] Add validation middleware
- [ ] Write integration tests

**Verification:**
- All API endpoints respond correctly
- Integration tests pass

### Milestone 4: Frontend Components (Day 4-5)
- [ ] Create component structure
- [ ] Build main components
- [ ] Connect to API
- [ ] Add state management
- [ ] Write component tests

**Verification:**
- All components render
- Component tests pass
- API integration works

### Milestone 5: Polish & Security (Day 6)
- [ ] Error handling
- [ ] Input validation
- [ ] Security review
- [ ] Performance optimization
- [ ] Documentation

**Verification:**
- No unhandled errors
- Security scan passes
- Performance meets targets

## Testing Strategy

### Unit Tests
- Test individual components/functions
- Mock dependencies
- Focus: Logic correctness
- Tool: Jest
- Target: 80%+ coverage

### Integration Tests
- Test component interactions
- Test API endpoints
- Test database operations
- Tool: Jest + Supertest
- Target: All workflows covered

### E2E Tests (Optional)
- Test full user flows
- Test in real browser
- Tool: Cypress or Playwright
- Target: Critical paths only

### Security Tests
- Input validation
- Authentication/authorization
- XSS prevention
- SQL injection prevention
- OWASP Top 10 checklist

## Deployment Strategy

### Build Process
```bash
npm run build
```
Produces:
- Compiled JavaScript
- Bundled assets
- Source maps for debugging

### Deployment Steps
1. Build production bundle
2. Run tests (must pass)
3. Security scan (must pass)
4. Deploy to production server/platform
5. Verify deployment

### Environment Configuration
```
.env.local       # Development secrets (not committed)
.env.production  # Production secrets (managed separately)
```

### Rollback Plan
- Keep previous version available
- Health checks post-deployment
- Quick rollback if issues detected

## Architecture Decisions & Rationale

### Decision 1: React for Frontend
**Rationale:**
- Large ecosystem of libraries
- Component reusability
- Strong testing support
- High developer productivity

**Alternatives Considered:**
- Vue: Simpler learning curve but smaller ecosystem
- Svelte: Smaller bundles but smaller community

### Decision 2: Express Backend
**Rationale:**
- Lightweight and flexible
- Great middleware ecosystem
- Matches Node.js ecosystem
- Easy testing with Supertest

**Alternatives Considered:**
- Fastify: Faster but less mature
- Next.js: Full-stack but overkill for API-first design

### Decision 3: Jest for Testing
**Rationale:**
- Industry standard for JavaScript
- Built-in mocking and snapshot testing
- Fast and reliable
- Good documentation

## Known Risks & Mitigation

### Risk 1: State Management Complexity
- **Impact:** Component prop drilling becomes unwieldy
- **Mitigation:** Use React Context or lightweight state library
- **Trigger:** When components > 5 levels deep

### Risk 2: Database Performance
- **Impact:** Slow queries as data grows
- **Mitigation:** Plan indexes and query optimization from start
- **Trigger:** Add monitoring and alerting in deployment

### Risk 3: Security Vulnerabilities
- **Impact:** Data breach, unauthorized access
- **Mitigation:** Security scan in testing phase, OWASP checklist
- **Trigger:** Zero-tolerance for critical issues

## Success Criteria

- [ ] All milestones completed
- [ ] 80%+ test coverage
- [ ] All tests passing
- [ ] Security scan clean
- [ ] Build succeeds
- [ ] Documentation complete
- [ ] Code follows style guidelines

## Next Phase

Implementation phase will follow this plan step-by-step using TDD:
1. Write failing tests
2. Write code to pass tests
3. Refactor for clarity
4. Commit with clear message
5. Repeat for each milestone

Code will be reviewed between milestones by code-reviewer agent.
```

**Actions:**
1. Create `.claude/prototypes/<project-name>/` directory if missing
2. Write plan.md with above structure
3. Fill in project-specific details from planning output
4. Include architecture diagram if helpful
5. Save path to state.artifacts.plan

---

## Step 6: Update State

**State Changes:**

```javascript
state.artifacts.plan = ".claude/prototypes/<project>/plan.md";
state.artifacts.worktree = "/path/to/worktree";

state.decisions.design = {
  architecture: "Component-based with hooks",
  file_structure: "src/{components,hooks,utils}",
  state_management: "React Context API",
  api_design: "RESTful with JSON",
  database: "PostgreSQL with ORM",
  validation_feedback: [...]  // From arch-infrastructure-reviewer
};
```

**Return to Orchestrator:**
```javascript
return {
  success: true,
  updated_state: state,
  plan_path: ".claude/prototypes/<project>/plan.md",
  worktree_path: "/path/to/worktree"
};
```

---

## Step 7: Mark Complete

Stage coordinator returns control to main orchestration skill, which:
1. Saves state checkpoint
2. Marks design as completed
3. Advances current_stage to "implementation"
4. Invokes stage-implementation coordinator

---

## MCP Integration

### Context7 Framework Patterns (Optional)

If available, use to enhance plan with framework-specific conventions:
```
Get patterns for:
  - React component structure
  - Express middleware pattern
  - Testing setup for framework
  - Project structure conventions
```

Merge into file_structure and implementation examples.

### Serena Context (Optional)

If available and resuming:
- Restore previous plan if exists
- Don't re-plan, use previous work
- Continue to implementation

---

## Error Handling

**If Writing-Plans Fails:**
- Display error message
- Return `{success: false}`
- State not updated, user can retry

**If Architecture Validation Fails:**
- Display issues
- Ask if user wants to revise or continue anyway
- If revise: loop back to step 2
- If continue: proceed (can address in implementation)

**If Worktree Creation Fails:**
- Log error
- Continue without worktree (can create manually)
- Note in state that worktree missing

---

## Example Output

### Design Complete ✅

```
Design Stage: Complete

Project: dashboard-app
Architecture: Component-based React frontend, Express API backend

Plan Structure:
  5 Milestones (6 days)
  - Setup & Configuration (Day 1)
  - Core Data Models (Day 2)
  - API Layer (Day 3)
  - Frontend Components (Days 4-5)
  - Polish & Security (Day 6)

File Structure:
  src/
    ├── components/ (React components)
    ├── hooks/ (Custom hooks)
    ├── utils/ (Helpers)
    └── styles/ (Tailwind CSS)

Tech Stack Validated:
  ✅ Architecture sound
  ✅ Scalability plan in place
  ✅ Security approach defined
  ✅ Testing strategy clear

Git Worktree:
  Created at: /Users/username/projects/dashboard-app-worktree

Plan saved to:
  .claude/prototypes/dashboard-app/plan.md

Next: Implementation phase will code to this plan using TDD
```

---

## Implementation Notes

- Design should be detailed enough for implementation, but not overly prescriptive
- Leave flexibility for implementation discoveries
- Document architectural decisions for future reference
- Include examples where helpful
- Plan should be achievable in 5-7 days of focused work
- Use TDD approach in next phase (tests first)
