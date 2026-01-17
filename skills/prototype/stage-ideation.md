---
name: prototype:stage-ideation
description: Ideation stage coordinator - clarifies requirements and tech stack
---

# Stage Ideation - Prototype Workflow

## Overview

The ideation stage clarifies project requirements and research best practices for the chosen tech stack. It produces a specification document and captures key technology decisions.

## Stage Input/Output Contract

**Input:**
- `project_name`: Name of project
- `state`: Initialized workflow state

**Output:**
- `success`: Boolean (true if stage completes)
- `updated_state`: State with populated tech_stack and decisions.ideation
- `spec_path`: Path to generated spec.md

**Flow:**
1. Invoke brainstorming skill (clarify requirements)
2. Research tech stack options (via Tavily if available)
3. Capture decisions
4. Write spec.md
5. Update and return state

---

## Step 1: Invoke Brainstorming Skill

**Purpose:** Clarify project requirements, features, target users, constraints

**Action:**
```
Invoke superpowers:brainstorming with:
  - Project name
  - Brief description (if available)
  - Context from any initial user input
```

**Brainstorming Skill Responsibility:**
- Ask clarifying questions about project
- Explore user intent, requirements, design
- Produce a specification with:
  - Project description
  - Key features/functionality
  - Target users/audience
  - Success criteria
  - Out-of-scope items
  - Non-functional requirements (performance, security, etc.)

**Capture From Brainstorming:**
- Core requirements
- Feature list (MVP)
- User persona/target
- Key constraints

---

## Step 2: Research Tech Stack

**Purpose:** Identify best-practice technologies for the project

**Action:**
If Tavily MCP available:
```
Search for:
  1. "[Project type] best practices 2025"
  2. "[Frontend framework] patterns and conventions"
  3. "[Backend framework] architecture recommendations"
  4. "Testing libraries [tech stack]"
  5. "CSS frameworks [project type]"

Aggregate findings into tech recommendations
```

If Tavily unavailable:
```
Use general knowledge from:
  - Frontend: React, Vue, Svelte, Angular (discuss tradeoffs)
  - Backend: Node.js, Python, Go, Rust (discuss tradeoffs)
  - Testing: Jest, Vitest, Pytest, RSpec (discuss tradeoffs)
  - Styling: Tailwind, Styled Components, SASS, CSS Modules

Ask user preferences if unclear
```

**Tech Stack Decisions to Make:**

1. **Frontend Framework**
   - React (ecosystem, learning curve, market demand)
   - Vue (simplicity, smaller bundle)
   - Svelte (performance, minimal overhead)
   - Angular (enterprise, complexity)
   - None (vanilla JS/HTML/CSS)

2. **Backend Framework** (if applicable)
   - Node.js + Express (JavaScript ecosystem)
   - Node.js + Next.js (full-stack React)
   - Python + FastAPI (modern, fast)
   - Python + Django (batteries included)
   - Go (performance, simplicity)
   - Rust (safety, performance)
   - None (serverless functions)

3. **Testing Framework**
   - Jest (Node.js/React standard)
   - Vitest (faster alternative)
   - Pytest (Python standard)
   - Go built-in testing
   - Cypress/Playwright (E2E)

4. **Styling Approach**
   - Tailwind CSS (utility-first, popular)
   - CSS-in-JS (styled-components, Emotion)
   - SASS/SCSS (preprocessor)
   - CSS Modules (scoped styles)
   - Component libraries (Material-UI, Chakra)

5. **Database** (if applicable)
   - PostgreSQL (relational, robust)
   - MongoDB (document-based)
   - SQLite (simple, file-based)
   - Firebase (serverless)
   - None (in-memory/stateless)

---

## Step 3: Capture Decisions

**Documentation Format:**

```json
{
  "ideation": {
    "project_description": "Build a real-time collaborative note-taking app",
    "target_users": "Small teams, educational settings",
    "key_features": [
      "Create/edit/share notes",
      "Real-time collaboration",
      "Rich text editing",
      "Comment threads"
    ],
    "constraints": [
      "Must work offline",
      "Support 50+ concurrent users",
      "Mobile-friendly"
    ],
    "tech_rationale": {
      "frontend": "React - large ecosystem, real-time libraries, component reusability",
      "backend": "Node.js/Express - single language, event-driven for real-time",
      "testing": "Jest + React Testing Library - standard for React projects",
      "styling": "Tailwind CSS - rapid development, consistent design"
    }
  }
}
```

**State Update:**
```json
{
  "tech_stack": {
    "frontend": "React + TypeScript",
    "backend": "Node.js + Express",
    "testing": "Jest + React Testing Library",
    "styling": "Tailwind CSS"
  },
  "decisions": {
    "ideation": {
      "project_description": "...",
      "target_users": "...",
      "key_features": [...],
      "constraints": [...],
      "tech_rationale": {...}
    }
  }
}
```

---

## Step 4: Write Specification

**File:** `.claude/prototypes/<project-name>/spec.md`

**Content Structure:**

```markdown
# Project Specification: <Project Name>

## Overview
<One paragraph description of project>

## Target Users / Audience
- Primary: <description>
- Secondary: <description>

## Key Features (MVP)
1. Feature 1 - <brief description>
2. Feature 2 - <brief description>
3. Feature 3 - <brief description>

## Out of Scope
- Feature X (why excluded)
- Feature Y (deferred to v2)

## Non-Functional Requirements
- Performance: <target metrics if applicable>
- Security: <key concerns>
- Scalability: <expected growth>
- Accessibility: <WCAG target if applicable>

## Tech Stack

### Frontend
- Framework: React + TypeScript
- Styling: Tailwind CSS
- State Management: (TBD in design phase)
- Build Tool: Vite (for speed)

### Backend
- Runtime: Node.js
- Framework: Express
- Database: PostgreSQL (for relational data)
- Authentication: JWT tokens

### Testing
- Unit: Jest
- Integration: Jest + Supertest
- E2E: Cypress or Playwright
- Security: ESLint security rules, OWASP Top 10 checks

### DevOps
- Version Control: Git
- CI/CD: GitHub Actions (if applicable)
- Hosting: TBD (deployment phase)

## Architecture Overview
<High-level diagram or description of how components interact>

## Success Criteria
- [ ] All MVP features implemented
- [ ] 80%+ test coverage
- [ ] Zero critical security issues
- [ ] Performance within targets
- [ ] Accessible to WCAG AA standard

## Timeline & Milestones (Optional)
- Week 1: Design & setup
- Week 2-3: Core features
- Week 4: Testing & refinement
- Week 5: Deployment prep

## Known Risks & Mitigations
- Risk: Real-time sync complexity
  Mitigation: Use established library (e.g., Yjs, Replicache)
- Risk: User growth > infrastructure capacity
  Mitigation: Plan for horizontal scaling from start

## Next Phase
Design phase will produce detailed implementation plan and architecture decisions.
```

**Actions:**
1. Create `.claude/prototypes/<project-name>/` directory if missing
2. Write spec.md with above structure
3. Fill in project-specific details from brainstorming output
4. Save to state.artifacts.spec

---

## Step 5: Update State

**State Changes:**

```javascript
state.tech_stack = {
  frontend: "React + TypeScript",
  backend: "Node.js + Express",
  testing: "Jest + React Testing Library",
  styling: "Tailwind CSS"
};

state.decisions.ideation = {
  project_description: "...",
  target_users: "...",
  key_features: [...],
  constraints: [...],
  tech_rationale: {...}
};

state.artifacts.spec = ".claude/prototypes/<project>/spec.md";
```

**Return to Orchestrator:**
```javascript
return {
  success: true,
  updated_state: state,
  spec_path: ".claude/prototypes/<project>/spec.md"
};
```

---

## Step 6: Mark Complete

Stage coordinator returns control to main orchestration skill, which:
1. Saves state checkpoint
2. Marks ideation as completed
3. Advances current_stage to "design"
4. Invokes stage-design coordinator

---

## MCP Integration

### Tavily Research (Optional)

If available, use for tech stack research:

```
Tavily searches:
  1. "React best practices patterns 2025"
  2. "Node.js Express architecture 2025"
  3. "Jest testing React components 2025"
  4. "Tailwind CSS workflow best practices"
  5. "[Project type] architecture patterns"
```

Aggregate into tech_rationale for decisions.

### Serena Context (Optional)

If available and resuming:
- Restore previous ideation decisions
- Don't re-brainstorm, use previous spec
- Continue to design phase

---

## Error Handling

**If Brainstorming Fails:**
- Display error message
- Return `{success: false}`
- State not updated, user can retry

**If Spec Writing Fails:**
- Log error
- Create minimal spec from captured decisions
- Continue to design (spec can be improved later)

**If Tech Stack Unclear:**
- Ask clarifying questions
- Provide recommendations
- Let user choose or accept defaults

---

## Example Output

### Ideation Complete ✅

```
Ideation Stage: Complete

Project: dashboard-app
Description: Real-time analytics dashboard for SaaS metrics

Tech Stack Selected:
  Frontend: React + TypeScript
  Backend: Node.js + Express
  Testing: Jest + React Testing Library
  Styling: Tailwind CSS

Key Features (5):
  1. Real-time data visualization
  2. Customizable dashboards
  3. Export to PDF/CSV
  4. User authentication
  5. Mobile responsive

Specification saved to:
  .claude/prototypes/dashboard-app/spec.md

Next: Design phase will create implementation plan
```

---

## Implementation Notes

- Ideation is conversational; embrace questions
- Tech stack should match project needs, not preferences
- Document reasoning for decisions (useful for design phase)
- If user wants to skip brainstorming: read requirements directly
- Spec.md is a living document (can be updated in later phases)
- Keep ideation focused on WHAT, not HOW (design handles HOW)
