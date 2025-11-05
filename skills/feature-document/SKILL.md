---
name: feature-document
description: Use when implementation is complete and tests pass - consolidates research, plan, implementation, and PR workflow (Z01-Z05) into timestamped dev log, cleans up all temporary files, and generates PR description
category: Documentation
---

# Feature Workflow: Document Implementation

**Skill Name:** feature-document (formerly development-logging)

## Overview

After successful implementation, consolidate all development artifacts (research, planning, implementation, PR reviews, fixes, and quality checks) into a single timestamped dev log, clean up all temporary Z01-Z05 files, and generate a PR description.

## When to Use

- Implementation from docs/ai/ongoing/Z02_plan.md is complete
- All tests pass
- Ready to document and create PR
- **After** superpowers:verification-before-completion

## When NOT to Use

- Implementation is incomplete or has failing tests
- No Z01/Z02 files exist (nothing to consolidate)
- Already have a dev log for this feature
- Working on exploratory/experimental code not ready for documentation
- Feature was abandoned or reverted
- Still actively addressing PR comments (wait until PR review cycle complete)

## Core Pattern

```
Implementation Complete + Tests Pass + PR Merged (if applicable)
    ↓
Create dev log (combines all Z01-Z05 files + implementation summary)
    ↓
Update README/docs if needed
    ↓
Clean up ALL temporary Z01-Z05 files
    ↓
Output PR description (or retrospective if PR already merged)
```

## Progress Tracking

**MANDATORY:** Use TodoWrite tool to track workflow progress.

**At skill start, create todos for all steps:**

```typescript
TodoWrite({
  todos: [
    {content: "Step 0: Detect repository pattern (DEV_LOGS_DIR, ONGOING_DIR)", status: "in_progress", activeForm: "Detecting documentation paths"},
    {content: "Step 1: Verify completion (tests pass, build succeeds)", status: "pending", activeForm: "Running verification checks"},
    {content: "Step 2: Create dev logs directory", status: "pending", activeForm: "Creating directory structure"},
    {content: "Step 3: Generate timestamp (YYYYMMDD)", status: "pending", activeForm: "Generating timestamp"},
    {content: "Step 4: Consolidate files (read Z01-Z05, create dev log)", status: "pending", activeForm: "Reading and consolidating Z-files"},
    {content: "Step 5: Update documentation (README, CHANGELOG, API docs)", status: "pending", activeForm: "Updating project documentation"},
    {content: "Step 6: Clean up temp files (remove ALL Z01-Z05)", status: "pending", activeForm: "Removing temporary files"},
    {content: "Step 7: Generate PR description", status: "pending", activeForm: "Creating PR description"},
    {content: "Step 8: Ask about PR creation (AskUserQuestion)", status: "pending", activeForm: "Awaiting user decision"}
  ]
})
```

**After completing each step:**
- Mark current step as `completed`
- Move `in_progress` to next step
- Update `activeForm` with current action

**Example update after Step 0:**
```typescript
TodoWrite({
  todos: [
    {content: "Step 0: Detect repository pattern (DEV_LOGS_DIR, ONGOING_DIR)", status: "completed"},
    {content: "Step 1: Verify completion (tests pass, build succeeds)", status: "in_progress", activeForm: "Running verification checks"},
    {content: "Step 2: Create dev logs directory", status: "pending"},
    // ... remaining steps
  ]
})
```

**CRITICAL:** Exactly ONE todo should be `in_progress` at any time. All others are `pending` or `completed`.

## Required Deliverables

1. **`$DEV_LOGS_DIR/{YYYYMMDD}_{feature}_dev_log.md`** - Consolidated development log (path detected in Step 0)
2. **Updated documentation** - README or relevant docs updated
3. **Cleanup** - ALL $ONGOING_DIR/Z01-Z05 files removed (Z01, Z02, Z03, Z04, Z05)
4. **PR description** - Concise, copy-pasteable description in code block
5. **User decision on PR** - Interactive prompt asking if user wants PR created (skip if PR already merged)

## Dev Log Structure

**File**: `docs/ai/dev_logs/{YYYYMMDD}_{feature}_dev_log.md`

```markdown
# {Feature} Development Log

**Date**: {YYYY-MM-DD}
**Status**: ✅ Complete

## Summary
One paragraph: what was built and why.

## Research Phase
[Content from docs/ai/ongoing/Z01_{feature}_research.md]

### Clarifications Resolved
[Content from docs/ai/ongoing/Z01_CLARIFY_{feature}_research.md with answers]

## Planning Phase
[Content from docs/ai/ongoing/Z02_{feature}_plan.md]

## Implementation
### What Was Done
- Bullet list of actual changes made
- Files created/modified with line ranges
- Key decisions during implementation

### Deviations from Plan
- What changed from original plan (if anything)
- Why changes were made

### Test Results
- Test coverage achieved
- Key test scenarios validated

## PR Workflow (if applicable)
### PR Review
[Content from docs/ai/ongoing/Z03_{pr}_review.md if exists]
- Review findings
- Security issues identified
- Code quality feedback

### PR Fixes
[Content from docs/ai/ongoing/Z04_{pr}_fix.md if exists]
- Comments addressed
- Changes made in response to review
- Discussion outcomes

### Quality Check
[Content from docs/ai/ongoing/Z05_{feature}_finish.md if exists]
- Pre-merge quality assessment
- Issues found and fixed
- Final verification

## Deployment Notes
- Environment variables added
- Configuration changes needed
- Migration steps (if any)

## Next Steps
- Follow-up work identified
- Technical debt created (if any)
- Future improvements
```

## Implementation Steps

### Step 0: Detect Repository Pattern

**Detect paths before proceeding:**

1. Check CLAUDE.md for documentation pattern
2. If not specified, scan for existing dev logs (example pattern pattern: `{YYYYMMDD}_*.md`)
3. If none found, scan for `dev_docs/`, `docs/ai/`, `.claude/` directories
4. Default: `docs/ai/dev_logs/` if nothing found

Set variables:
- `DEV_LOGS_DIR` - Where dev log goes
- `ONGOING_DIR` - Where Z01/Z02 files are (check Z01/Z02 locations separately)

### Step 1: Verify Completion

Before creating dev log, confirm:
```bash
# Tests pass
pytest

# Build succeeds
# (run project-specific build command)
```

### Step 2: Create Directory

```bash
# Create if doesn't exist (using detected pattern)
mkdir -p $DEV_LOGS_DIR
```

### Step 3: Generate Timestamp

```bash
# Format: YYYYMMDD
date +%Y%m%d
# Example: 20241028
```

### Step 4: Consolidate Files

Read and combine ALL available Z-files (using detected paths):

**Required (must exist):**
1. $ONGOING_DIR/Z01_{feature}_research.md
2. $ONGOING_DIR/Z01_CLARIFY_{feature}_research.md (with user answers, if exists)
3. $ONGOING_DIR/Z02_{feature}_plan.md
4. Implementation summary (what you actually did)

**Optional (include if exist):**
5. $ONGOING_DIR/Z03_*_review.md (PR review notes from feature-prreview)
6. $ONGOING_DIR/Z04_*_fix.md (PR fix tracking from feature-prfix)
7. $ONGOING_DIR/Z05_*_finish.md (Quality assessment from feature-finish)

Use bash to check for optional files:
```bash
# Check for Z03/Z04/Z05 files
ls $ONGOING_DIR/Z03_*.md 2>/dev/null && echo "Found Z03 (PR review)"
ls $ONGOING_DIR/Z04_*.md 2>/dev/null && echo "Found Z04 (PR fix)"
ls $ONGOING_DIR/Z05_*.md 2>/dev/null && echo "Found Z05 (Quality check)"
```

Write to: `$DEV_LOGS_DIR/{YYYYMMDD}_{feature}_dev_log.md`

### Step 5: Update Documentation

Check if these need updates:
- README.md - New features, setup instructions
- CHANGELOG.md - Version history
- API docs - New endpoints
- Architecture docs - System changes

### Step 6: Clean Up Temp Files

```bash
# Remove ALL Z01-Z05 files from ongoing directory (using detected path)
rm $ONGOING_DIR/Z01_* 2>/dev/null || true
rm $ONGOING_DIR/Z02_* 2>/dev/null || true
rm $ONGOING_DIR/Z03_* 2>/dev/null || true
rm $ONGOING_DIR/Z04_* 2>/dev/null || true
rm $ONGOING_DIR/Z05_* 2>/dev/null || true

# Verify cleanup
echo "Remaining Z-files:"
ls $ONGOING_DIR/Z0*.md 2>/dev/null || echo "✓ All Z-files cleaned up"
```

**IMPORTANT:** This cleans up temporary files from:
- Z01: Research (feature-research)
- Z02: Plan (feature-plan)
- Z03: PR Review (feature-prreview)
- Z04: PR Fix (feature-prfix)
- Z05: Quality Check (feature-finish)

### Step 7: Generate PR Description

Format:
```markdown
## Summary
One sentence: what this PR does.

## Changes
- Key change 1
- Key change 2
- Key change 3

## Testing
- Test approach
- Coverage: X%

## Deployment Notes
- Environment variables (if any)
- Migration steps (if any)
```

### Step 8: Ask About PR Creation

Use AskUserQuestion: "Would you like me to create a pull request now?"

**If Yes:** Verify feature branch, commit, push, run `gh pr create`, return URL
**If No:** Confirm completion, remind user to commit/push/create PR manually

## Example Output

```markdown
Detected pattern: dev_docs/ (from CLAUDE.md)

**Files Created:**
- dev_docs/20241028_oauth_authentication_dev_log.md

**Documentation Updated:**
- README.md - Added OAuth setup instructions
- CHANGELOG.md - v2.1.0 entry

**Cleaned Up:**
- dev_docs/ongoing/Z01_* (research - removed)
- dev_docs/ongoing/Z02_* (plan - removed)
- dev_docs/ongoing/Z03_* (PR review - removed, if existed)
- dev_docs/ongoing/Z04_* (PR fix - removed, if existed)
- dev_docs/ongoing/Z05_* (quality check - removed, if existed)

**PR Description:**

```
## Summary
Implements OAuth 2.0 authentication with PKCE for API security.

## Changes
- Added FastAPI OAuth endpoints (authorize, token, revoke)
- Created 4 database tables for OAuth data
- Implemented JWT token validation middleware
- Added rate limiting (5 req/min per endpoint)

## Testing
- Unit tests for auth logic (95% coverage)
- Integration tests for full OAuth flow
- Security tests for token validation

## Deployment Notes
- Set AUTH_SECRET_KEY in environment
- Run database migration: `alembic upgrade head`
- Update CORS_ALLOWED_ORIGINS config
```

[Interactive prompt: "Would you like me to create a pull request now?"]
```

## Common Mistakes

| Mistake | Fix |
|---------|-----|
| Skipping Step 0 (pattern detection) | ALWAYS detect repo pattern first |
| Using hardcoded paths (docs/ai/) | Use detected DEV_LOGS_DIR and ONGOING_DIR |
| Creating dev log before tests pass | Run tests FIRST, then create log |
| Only removing Z01/Z02 files | Must remove ALL Z01-Z05 files |
| Not checking for Z03/Z04/Z05 | Check for optional files and include in dev log |
| Vague PR description | Be specific: what, why, how |
| Not updating README | Check if setup/usage docs need updates |
| Missing deployment notes | Document env vars, migrations |
| Not asking about PR creation | MUST use AskUserQuestion for PR prompt |
| Not using TodoWrite to track steps | Use TodoWrite from start to track all 9 steps |
| Skipping TodoWrite updates | Mark steps completed immediately, keep ONE in_progress |

## Red Flags - STOP and Fix

- Skipped Step 0 (repo pattern detection)
- Using hardcoded paths instead of detected variables
- Tests failing (don't create dev log yet)
- Z01/Z02 files not removed (must remove ALL Z01-Z05)
- Didn't check for Z03/Z04/Z05 files
- Z03/Z04/Z05 files exist but not included in dev log
- No PR description generated
- Documentation not checked
- Dev log missing implementation section
- Didn't ask user about PR creation

**All of these mean**: Complete the step before proceeding.

## Success Criteria

Development logging is complete when:
- [ ] Repository documentation pattern detected (Step 0)
- [ ] DEV_LOGS_DIR and ONGOING_DIR variables set correctly
- [ ] All tests pass
- [ ] $DEV_LOGS_DIR/{YYYYMMDD}_{feature}_dev_log.md created
- [ ] Dev log contains: research + plan + implementation
- [ ] Dev log contains: PR workflow sections (if Z03/Z04/Z05 existed)
- [ ] Checked for Z03/Z04/Z05 files and included them if present
- [ ] README/docs updated if needed
- [ ] ALL $ONGOING_DIR/Z01-Z05 temp files removed
- [ ] Verified no Z0*.md files remain in $ONGOING_DIR
- [ ] PR description generated in code block
- [ ] User prompted about PR creation (AskUserQuestion tool used)
- [ ] PR created (if user selected "Yes") OR next steps communicated (if user selected "No")
