---
name: prototype:stage-deployment
description: Deployment prep coordinator - builds artifacts and documentation
---

# Stage Deployment - Prototype Workflow

## Overview

The deployment prep stage finalizes the prototype for deployment. It verifies the build, generates/updates documentation, creates a final commit, and marks the workflow complete. The code is ready to be merged and deployed by the user.

## Stage Input/Output Contract

**Input:**
- `project_name`: Name of project
- `state`: Current workflow state (with testing complete)
- `worktree_path`: Path to git worktree with tested code

**Output:**
- `success`: Boolean (true if prep complete)
- `updated_state`: State with deployment marked complete
- `ready_for_deployment`: Boolean (true if code is deployable)

**Flow:**
1. Verify build succeeds
2. Generate/update README
3. Ensure documentation complete
4. Create final commit
5. Prepare deployment summary
6. Mark workflow complete

---

## Step 1: Change to Worktree

**Action:**
```bash
cd <worktree_path>
pwd
git status
```

**Verification:**
- Git repo exists and clean
- Code is implemented (from implementation stage)
- Tests passed (from testing stage)
- Build succeeded (from testing stage)

---

## Step 2: Verify Production Build

**Purpose:** Ensure build artifacts can be created

**Action:**
```bash
npm run build
```

**Expected Output:**
```
$ npm run build
> build
> vite build

vite v4.0.0 building for production...
✓ 2,341 modules transformed.

dist/index.html                   0.46 kB │ gzip:  0.32 kB
dist/assets/index.abc123.js     547.89 kB │ gzip: 142.33 kB
dist/assets/index.xyz789.css    12.34 kB │ gzip:  2.45 kB

✓ built in 12.34s
```

**Verification:**
- No errors in output
- `dist/` or `build/` directory created
- All assets present

**If Build Fails:**
1. Save state at deployment stage
2. Return `{success: false, failure: "build_failed"}`
3. User can fix and resume

---

## Step 3: Generate README (if missing)

**Purpose:** Provide setup and deployment instructions

**File:** `README.md` in project root

**Content Structure:**

```markdown
# <Project Name>

<One-line description>

## Overview

<2-3 paragraph description of project, its purpose, key features>

## Features

- Feature 1
- Feature 2
- Feature 3

## Tech Stack

- **Frontend:** React + TypeScript
- **Backend:** Node.js + Express
- **Testing:** Jest + React Testing Library
- **Styling:** Tailwind CSS
- **Build Tool:** Vite

## Prerequisites

- Node.js 18+
- npm 8+
- Git

## Installation

1. Clone the repository
```bash
git clone https://github.com/username/project-name.git
cd project-name
```

2. Install dependencies
```bash
npm install
```

3. Configure environment
```bash
cp .env.example .env.local
# Edit .env.local with your configuration
```

## Development

Start the development server:
```bash
npm run dev
```

The application will be available at `http://localhost:5173`

## Building for Production

Create a production build:
```bash
npm run build
```

Build artifacts are in `dist/` directory.

## Testing

Run the test suite:
```bash
npm test
```

Run tests with coverage:
```bash
npm test -- --coverage
```

Run specific test file:
```bash
npm test -- src/components/Header.test.tsx
```

## Code Quality

Lint code:
```bash
npm run lint
```

Type check:
```bash
npm run type-check
```

## Project Structure

```
project-root/
├── src/
│   ├── components/          # React components
│   ├── hooks/               # Custom React hooks
│   ├── utils/               # Utility functions
│   ├── styles/              # Stylesheets
│   └── App.tsx              # Root component
├── tests/
│   ├── unit/                # Unit tests
│   ├── integration/         # Integration tests
│   └── fixtures/            # Test data
├── public/                  # Static assets
├── dist/                    # Production build (generated)
├── package.json             # Dependencies and scripts
├── tsconfig.json            # TypeScript configuration
├── jest.config.js           # Testing configuration
└── README.md                # This file
```

## Architecture

### Frontend Components
- `Header` - Navigation and branding
- `Dashboard` - Main content area
- `Sidebar` - Additional navigation
- `Form` - User input component

### API Endpoints
- `GET /api/items` - List items
- `POST /api/items` - Create item
- `GET /api/items/:id` - Get item details
- `PUT /api/items/:id` - Update item
- `DELETE /api/items/:id` - Delete item

### Database Models
- User - User account information
- Item - Main domain object
- Comment - User feedback

## Configuration

Environment variables:
```
VITE_API_URL=http://localhost:3000/api
VITE_APP_NAME=Project Name
NODE_ENV=development
```

## Deployment

### Prerequisites
- Build artifacts generated (`npm run build`)
- All tests passing
- Security scan clean

### Deployment Options

#### Option 1: Vercel (Recommended for Frontend)
1. Push code to GitHub
2. Connect to Vercel
3. Vercel automatically builds and deploys

#### Option 2: Netlify
1. Connect repository to Netlify
2. Set build command: `npm run build`
3. Set publish directory: `dist`

#### Option 3: Docker
```dockerfile
FROM node:18-alpine
WORKDIR /app
COPY . .
RUN npm install && npm run build
EXPOSE 3000
CMD ["npm", "run", "start"]
```

#### Option 4: Manual Deployment
1. Run `npm run build`
2. Upload `dist/` contents to your server
3. Configure web server to serve `index.html`
4. Set up environment variables on server

## Troubleshooting

### Build Fails
- Ensure all dependencies installed: `npm install`
- Check TypeScript errors: `npm run type-check`
- Clear cache: `rm -rf node_modules && npm install`

### Tests Fail
- Run tests with verbose output: `npm test -- --verbose`
- Check that all dependencies installed
- Review test error messages for specifics

### Runtime Errors
- Check console for error messages
- Verify environment variables set correctly
- Check network requests in browser DevTools

## Contributing

1. Create a feature branch: `git checkout -b feature/your-feature`
2. Make your changes and commit: `git commit -m "feat: description"`
3. Push to branch: `git push origin feature/your-feature`
4. Create a Pull Request

## License

MIT License - See LICENSE file for details

## Contact

- Author: [Your Name]
- Email: your.email@example.com
- GitHub: https://github.com/username

## Changelog

### Version 1.0.0 (Initial Release)
- Initial implementation
- All core features complete
- Tests passing
- Security reviewed

---

**Generated by Prototype Workflow**
Date: <current_date>
```

**Actions:**
1. Check if README.md exists
2. If missing: generate full README from template above
3. If exists: update with latest information
4. Add generation note at bottom with current date

---

## Step 4: Generate Deployment Documentation

**File:** `DEPLOYMENT.md` (optional but recommended)

**Content:**

```markdown
# Deployment Guide

## Pre-Deployment Checklist

- [ ] All tests passing: `npm test`
- [ ] Build succeeds: `npm run build`
- [ ] No TypeScript errors: `npm run type-check`
- [ ] Code linted: `npm run lint`
- [ ] Security scan clean (see SECURITY.md)
- [ ] Environment variables configured
- [ ] Database migrations applied (if applicable)

## Build Information

**Build Date:** <current_date>
**Build Command:** `npm run build`
**Build Output:** `dist/` directory
**Build Size:** Check `dist/` for asset sizes

## Environment Setup

### Development
```
VITE_API_URL=http://localhost:3000/api
NODE_ENV=development
```

### Production
```
VITE_API_URL=https://api.example.com
NODE_ENV=production
```

## Deployment Steps

1. **Verify Build**
   ```bash
   npm run build
   # Check dist/ directory created
   ```

2. **Upload to Server**
   - Upload contents of `dist/` to web server
   - Keep directory structure intact

3. **Configure Web Server**
   - Point root to `dist/index.html`
   - Set up routing to serve SPA (all routes go to index.html)

4. **Configure Environment**
   - Set environment variables on server
   - Configure API endpoints
   - Set up domain/SSL

5. **Verify Deployment**
   - Load application in browser
   - Test critical user flows
   - Check console for errors

## Rollback Plan

If issues detected post-deployment:
1. Revert to previous version
2. Investigate issues locally
3. Fix and re-test
4. Redeploy

## Performance Monitoring

After deployment, monitor:
- Page load times
- Error rates
- User engagement
- Server logs

## Security Considerations

- HTTPS required for production
- API endpoints should be HTTPS
- Secrets should be environment variables (not in code)
- Regular dependency updates recommended
- Monitor security advisories

## Scaling Considerations

For high traffic:
- Consider CDN for static assets
- Set up caching headers on web server
- Monitor server resources
- Scale database if needed

---

**Generated by Prototype Workflow**
```

**Actions:**
1. Generate DEPLOYMENT.md in project root
2. Save path to state for reference

---

## Step 5: Generate Security Documentation (if needed)

**File:** `SECURITY.md` (optional)

**Content:**

```markdown
# Security Information

## Security Scan Results

### Date: <current_date>
### Status: ✅ PASSED

### Critical Issues: 0
✅ No critical vulnerabilities identified

### Medium Issues:
- [List any medium issues found in testing]

### Low Issues:
- [List any low issues found in testing]

## Security Practices Implemented

- ✅ Input validation on all user inputs
- ✅ OWASP Top 10 compliance verified
- ✅ Authentication/authorization implemented
- ✅ Secrets not committed to repository
- ✅ Dependencies regularly updated
- ✅ HTTPS enforced in production
- ✅ CSRF protection enabled
- ✅ XSS prevention measures in place

## Reporting Security Issues

If you discover a security vulnerability:
1. **Do NOT** create a public issue
2. Email: security@example.com
3. Include detailed description and reproduction steps
4. We will acknowledge within 24 hours

## Regular Security Updates

- Dependency updates: Monthly
- Security audit: Quarterly
- Penetration testing: Annually

---

**Generated by Prototype Workflow**
```

**Actions:**
1. Generate SECURITY.md if testing found issues
2. Or create template for user to update

---

## Step 6: Update Existing Documentation

**Files to Update:**

1. **package.json** - Ensure all fields are present
   ```json
   {
     "name": "project-name",
     "version": "1.0.0",
     "description": "Project description",
     "main": "dist/index.js",
     "scripts": { ... },
     "keywords": ["prototype"],
     "author": "Your Name",
     "license": "MIT",
     "repository": {
       "type": "git",
       "url": "https://github.com/username/project-name.git"
     }
   }
   ```

2. **.gitignore** - Ensure standard entries
   ```
   node_modules/
   dist/
   build/
   coverage/
   .env
   .env.local
   .DS_Store
   *.log
   ```

3. **.env.example** - Template for environment variables
   ```
   VITE_API_URL=http://localhost:3000/api
   VITE_APP_NAME=Project Name
   ```

---

## Step 7: Final Verification

**Checklist:**

```bash
# Verify all required files exist
ls -la README.md
ls -la package.json
ls -la dist/  # or build/

# Verify git history
git log --oneline | head -10

# Verify no uncommitted changes
git status

# Final test run
npm test -- --passWithNoTests
```

---

## Step 8: Create Final Commit

**Action:**
```bash
git add .
git commit -m "docs: Ready for deployment

- Final README generated/updated
- Deployment guide created
- Security documentation complete
- All tests passing
- Build verified
- Ready for production deployment

Workflow: ✅ Complete
Date: <current_date>"
```

**Verification:**
```bash
git log --oneline | head -5
# Shows recent commits including final deployment commit
```

---

## Step 9: Generate Completion Summary

**Format:**

```markdown
# Prototype Workflow - Completion Summary

## Project: <Project Name>
**Completed:** <Date>

## Workflow Status: ✅ COMPLETE

### Stages Completed
1. ✅ Ideation - Requirements & tech stack defined
2. ✅ Design - Architecture & implementation plan created
3. ✅ Implementation - All code written with TDD
4. ✅ Testing - All tests pass, security verified
5. ✅ Deployment Prep - Artifacts ready, docs complete

## Final Statistics

**Code Quality:**
- Total files created: 47
- Components/modules: 12
- Test coverage: 87.9%
- Linting: ✅ Pass
- Type checking: ✅ Pass

**Testing:**
- Unit tests: 65/65 passing
- Integration tests: 19/19 passing
- Total: 84/84 passing
- Security issues: 0 critical, 1 medium

**Build:**
- Build size: 547.89 KB (gzip: 142.33 KB)
- Time: 12.34s
- Status: ✅ Success

## Artifacts Delivered

**Code:**
- Git worktree with complete implementation
- 23 commits with clear messages
- All tests passing
- Build verified

**Documentation:**
- README.md - Setup and usage instructions
- DEPLOYMENT.md - Deployment guide
- SECURITY.md - Security information
- Specification (spec.md)
- Implementation Plan (plan.md)

**Test Results:**
- All 84 tests passing
- 87.9% code coverage
- Security scan clean

## Next Steps for Deployment

1. **Review Code**
   - Browse implementation in worktree
   - Review commits and changes
   - Verify against original requirements

2. **Merge to Main**
   - Merge worktree back to main branch
   - Or integrate into existing repo

3. **Deploy**
   - Follow DEPLOYMENT.md guide
   - Choose deployment platform
   - Monitor post-deployment

4. **Monitor**
   - Track performance
   - Monitor error rates
   - Respond to issues

## Project Structure

```
<worktree>/
├── src/                      # Implementation code
├── tests/                    # Test suites
├── dist/                     # Build artifacts
├── public/                   # Static assets
├── README.md                 # User guide
├── DEPLOYMENT.md             # Deployment guide
├── SECURITY.md               # Security info
├── package.json              # Dependencies
└── .git/                     # Git history
```

## Recommendations

1. **Immediate Actions**
   - Review code implementation
   - Merge to main branch
   - Begin deployment process

2. **Short-term**
   - Deploy to production
   - Monitor for issues
   - Gather user feedback

3. **Long-term**
   - Plan feature updates
   - Regular security audits
   - Dependency management
   - Performance optimization

## Support

For questions about this prototype:
- Review generated documentation
- Check git commit messages
- Review implementation plan (plan.md)
- Review specification (spec.md)

---

**Generated by Prototype Workflow**
Version 1.0 - <Date>
```

---

## Step 10: Update State

**State Changes:**

```javascript
state.current_stage = null;  // Workflow complete
state.completed_stages = ["ideation", "design", "implementation", "testing", "deployment"];

state.artifacts.readme = "README.md";
state.artifacts.deployment_guide = "DEPLOYMENT.md";
state.artifacts.security_docs = "SECURITY.md";

state.final_status = "COMPLETE";
state.ready_for_deployment = true;
```

**Return to Orchestrator:**
```javascript
return {
  success: true,
  updated_state: state,
  ready_for_deployment: true,
  deployment_path: "<worktree_path>",
  documentation: {
    readme: "README.md",
    deployment: "DEPLOYMENT.md",
    security: "SECURITY.md"
  }
};
```

---

## Step 11: Display Success Message

**Action:**
```
🎉 Prototype Workflow Complete!

Project: dashboard-app
Status: ✅ READY FOR DEPLOYMENT

Workflow Stages:
  ✅ Ideation - Requirements captured
  ✅ Design - Architecture designed
  ✅ Implementation - Code written
  ✅ Testing - All tests passing
  ✅ Deployment Prep - Artifacts ready

Code Delivered:
  - 47 files created
  - 84 tests (all passing)
  - 87.9% coverage
  - 23 atomic commits
  - Production build ready

Documentation:
  - README.md - Setup and usage
  - DEPLOYMENT.md - Deployment guide
  - SECURITY.md - Security info
  - Implementation plan
  - Test results

Git Worktree:
  Location: /path/to/dashboard-app-worktree
  Branch: main
  Commits: 23
  Status: Clean

Next Steps:
1. Review implementation in worktree
2. Merge worktree to main branch
3. Follow DEPLOYMENT.md for deployment
4. Monitor post-deployment

Thank you for using Prototype Workflow!
```

---

## Step 12: Mark Workflow Complete

Stage coordinator returns control to main orchestration skill, which:
1. Marks workflow as complete
2. Sets current_stage to null
3. Saves final state
4. Displays completion summary

---

## Error Handling

**Build Fails:**
- Save state at deployment stage
- Return failure
- User can fix and resume

**Documentation Generation Fails:**
- Create minimal docs
- Continue (docs can be improved manually)
- Save what was created

**Worktree Issues:**
- Log warnings
- Continue (user can manually verify)
- Provide instructions in output

---

## Example Output

### Deployment Complete ✅

```
Deployment Prep: Complete

Project: dashboard-app

Build Artifacts:
  ✓ dist/ directory created
  ✓ Size: 547.89 KB (gzip: 142.33 KB)
  ✓ All assets present

Documentation:
  ✓ README.md - Updated with setup instructions
  ✓ DEPLOYMENT.md - Deployment guide created
  ✓ SECURITY.md - Security summary generated
  ✓ package.json - All fields complete
  ✓ .gitignore - Configured

Final Commit:
  ✓ All changes committed
  ✓ Commit message: "docs: Ready for deployment"

Workflow Complete: ✅ YES

Ready for Deployment:
  - Code in worktree: /path/to/dashboard-app-worktree
  - All tests passing: 84/84
  - Security verified: 0 critical issues
  - Documentation complete: 3 guides
  - Build successful: Production artifacts ready

Next Steps:
  1. Review code in worktree
  2. Merge to main branch
  3. Deploy following DEPLOYMENT.md
  4. Monitor performance post-deployment

🎉 Project ready for production!
```

---

## Implementation Notes

- Build must succeed to proceed
- All documentation must be generated
- Final commit should be clear and descriptive
- Workflow is non-blocking at this stage (can be improved manually)
- Code is ready for user to deploy as-is
- All support documentation provided for deployment
