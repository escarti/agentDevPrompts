---
name: development-logging
description: Use when implementation is complete and tests pass - consolidates research, plan, and implementation into timestamped dev log, cleans up temporary files, and generates PR description
category: Documentation
---

# Development Logging

## Overview

After successful implementation, consolidate all development artifacts into a single timestamped dev log, clean up temporary files, and generate a PR description.

## When to Use

- Implementation from docs/ai/ongoing/Z02_plan.md is complete
- All tests pass
- Ready to document and create PR
- **After** superpowers:verification-before-completion

## Core Pattern

```
Implementation Complete + Tests Pass
    ↓
Create dev log (combines docs/ai/ongoing/Z01 + Z02 + summary)
    ↓
Update README/docs if needed
    ↓
Clean up docs/ai/ongoing/Z01/Z02 temp files
    ↓
Output PR description
```

## Required Deliverables

1. **`docs/ai/dev_logs/{YYYYMMDD}_{feature}_dev_log.md`** - Consolidated development log
2. **Updated documentation** - README or relevant docs updated
3. **Cleanup** - docs/ai/ongoing/Z01 and Z02 files removed
4. **PR description** - Concise, copy-pasteable description in code block

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
# Create if doesn't exist
mkdir -p docs/ai/dev_logs
```

### Step 3: Generate Timestamp

```bash
# Format: YYYYMMDD
date +%Y%m%d
# Example: 20241028
```

### Step 4: Consolidate Files

Read and combine:
1. docs/ai/ongoing/Z01_{feature}_research.md
2. docs/ai/ongoing/Z01_CLARIFY_{feature}_research.md (with user answers)
3. docs/ai/ongoing/Z02_{feature}_plan.md
4. Implementation summary (what you actually did)

Write to: `docs/ai/dev_logs/{YYYYMMDD}_{feature}_dev_log.md`

### Step 5: Update Documentation

Check if these need updates:
- README.md - New features, setup instructions
- CHANGELOG.md - Version history
- API docs - New endpoints
- Architecture docs - System changes

### Step 6: Clean Up Temp Files

```bash
# Remove Z01 and Z02 files from ongoing directory
rm docs/ai/ongoing/Z01_*
rm docs/ai/ongoing/Z02_*
```

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

## Example Output

```markdown
I've completed the implementation and created the development log.

**Files Created:**
- docs/ai/dev_logs/20241028_oauth_authentication_dev_log.md

**Documentation Updated:**
- README.md - Added OAuth setup instructions
- CHANGELOG.md - v2.1.0 entry

**Cleaned Up:**
- docs/ai/ongoing/Z01_oauth_authentication_research.md (removed)
- docs/ai/ongoing/Z01_CLARIFY_oauth_authentication_research.md (removed)
- docs/ai/ongoing/Z02_oauth_authentication_plan.md (removed)

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
```

## Common Mistakes

| Mistake | Fix |
|---------|-----|
| Creating dev log before tests pass | Run tests FIRST, then create log |
| Forgetting to remove Z01/Z02 files | Must clean up temp files |
| Vague PR description | Be specific: what, why, how |
| Not updating README | Check if setup/usage docs need updates |
| Missing deployment notes | Document env vars, migrations |

## Red Flags - STOP and Fix

- Tests failing (don't create dev log yet)
- Z01/Z02 files not removed
- No PR description generated
- Documentation not checked
- Dev log missing implementation section

**All of these mean**: Complete the step before proceeding.

## Success Criteria

Development logging is complete when:
- [ ] All tests pass
- [ ] docs/ai/dev_logs/{YYYYMMDD}_{feature}_dev_log.md created
- [ ] Dev log contains: research + plan + implementation
- [ ] README/docs updated if needed
- [ ] docs/ai/ongoing/Z01/Z02 temp files removed
- [ ] PR description generated in code block
- [ ] Ready to commit and create PR
