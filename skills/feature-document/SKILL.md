---
name: feature-document
description: Use when implementation is complete and tests pass - consolidates research, plan, implementation, and PR workflow (Z01-Z05) into timestamped dev log, cleans up all temporary files, and generates PR description
category: Documentation
---

# Feature Workflow: Document Implementation

## YOU ARE READING THIS SKILL RIGHT NOW

**STOP. Before doing ANYTHING else:**

1. ☐ Create TodoWrite checklist (see below)
2. ☐ Mark Step 1 as `in_progress`
3. ☐ Verify tests pass (don't document if failing)

**This skill consolidates Z01-Z05 files and DELETES them. Make sure implementation is complete.**

## MANDATORY FIRST ACTION: Create TodoWrite

```typescript
TodoWrite({
  todos: [
    {content: "Step 1: Verify tests pass", status: "in_progress", activeForm: "Running tests"},
    {content: "Step 2: Find Z01/Z02 files and detect paths", status: "pending", activeForm: "Finding Z-files"},
    {content: "Step 3: Create dev log with all Z-files", status: "pending", activeForm: "Writing dev log"},
    {content: "Step 4: Update README/docs if needed", status: "pending", activeForm: "Updating docs"},
    {content: "Step 5: Clean up ALL Z01-Z05 files", status: "pending", activeForm: "Removing temp files"},
    {content: "Step 6: Generate PR description", status: "pending", activeForm: "Creating PR description"},
    {content: "Step 7: Ask about PR creation (AskUserQuestion)", status: "pending", activeForm: "Awaiting user choice"}
  ]
})
```

**After each step:** Mark completed, move `in_progress` to next step.

## When to Use

- Implementation complete
- All tests pass
- Ready to document and create PR
- After verification-before-completion

## When NOT to Use

- Implementation incomplete or tests failing
- No Z01/Z02 files exist
- Already have dev log for this feature
- PR already merged (unless creating retrospective)

## Workflow Steps

### Step 1: Verify Tests Pass

Run tests:
```bash
pytest  # or npm test, etc.
```

**If tests fail:** Stop. Fix tests first.

---

### Step 2: Find Z-files and Detect Paths

Scan for Z01/Z02 files in common locations:
- docs/ai/ongoing
- .ai/ongoing
- docs/ongoing

**Find feature name** from Z02 filename: `Z02_{feature}_plan.md`

**Detect dev log directory:**
- Check CLAUDE.md for pattern
- Look for existing dev logs
- Default: docs/ai/dev_logs/

**Save variables:**
- ONGOING_DIR (where Z-files are)
- DEV_LOGS_DIR (where dev log goes)
- Feature name (from Z02 filename)

---

### Step 3: Create Dev Log

**Location:** `{DEV_LOGS_DIR}/{YYYYMMDD}_{feature}_dev_log.md`

**Generate timestamp:** `date +%Y%m%d` (Example: 20241028)

**Structure:**
```markdown
# {Feature} Development Log

**Date**: {YYYY-MM-DD}
**Status**: ✅ Complete

## Summary
One paragraph: what was built and why.

## Research Phase
[Content from Z01_{feature}_research.md]

### Clarifications Resolved
[Content from Z01_CLARIFY_{feature}_research.md if exists]

## Planning Phase
[Content from Z02_{feature}_plan.md]

## Implementation
### What Was Done
- Actual changes made
- Files created/modified
- Key decisions

### Deviations from Plan
- What changed (if anything)
- Why changes were made

### Test Results
- Coverage achieved
- Key scenarios validated

## PR Workflow (if applicable)
### PR Review
[Content from Z03_*_review.md if exists]

### PR Fixes
[Content from Z04_*_fix.md if exists]

### Quality Check
[Content from Z05_*_finish.md if exists]

## Deployment Notes
- Environment variables
- Configuration changes
- Migration steps

## Next Steps
- Follow-up work
- Technical debt
- Future improvements
```

**Check for optional files:**
```bash
ls {ONGOING_DIR}/Z03_*.md 2>/dev/null && echo "Found Z03 (PR review)"
ls {ONGOING_DIR}/Z04_*.md 2>/dev/null && echo "Found Z04 (PR fix)"
ls {ONGOING_DIR}/Z05_*.md 2>/dev/null && echo "Found Z05 (Quality check)"
```

Include them in dev log if they exist.

---

### Step 4: Update Documentation

Check if these need updates:
- README.md - New features, setup
- CHANGELOG.md - Version history
- API docs - New endpoints

---

### Step 5: Clean Up ALL Z-files

**CRITICAL: Delete ALL temporary files:**

```bash
rm {ONGOING_DIR}/Z01_*.md 2>/dev/null || true
rm {ONGOING_DIR}/Z02_*.md 2>/dev/null || true
rm {ONGOING_DIR}/Z03_*.md 2>/dev/null || true
rm {ONGOING_DIR}/Z04_*.md 2>/dev/null || true
rm {ONGOING_DIR}/Z05_*.md 2>/dev/null || true

# Verify cleanup
ls {ONGOING_DIR}/Z0*.md 2>/dev/null || echo "✓ All Z-files cleaned up"
```

**This deletes:**
- Z01: Research (feature-research)
- Z02: Plan (feature-plan)
- Z03: PR Review (feature-prreview)
- Z04: PR Fix (feature-prfix)
- Z05: Quality Check (feature-finish)

---

### Step 6: Generate PR Description

**Format:**
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

---

### Step 7: Ask About PR Creation

**Use AskUserQuestion tool:**

```typescript
AskUserQuestion({
  questions: [{
    question: "Would you like me to create a pull request now?",
    header: "PR Creation",
    multiSelect: false,
    options: [
      {label: "Yes", description: "Commit, push, and create PR with gh CLI"},
      {label: "No", description: "I'll create the PR manually"}
    ]
  }]
})
```

**If Yes:**
- Commit changes
- Push to remote
- Run `gh pr create` with generated description
- Return PR URL

**If No:**
- Confirm completion
- Remind user to commit/push/create PR manually

---

## Red Flags - You're Failing If:

- **Tests failing but creating dev log anyway**
- **Using hardcoded paths instead of detecting pattern**
- **Only removing Z01/Z02 (must remove ALL Z01-Z05)**
- **Not checking for Z03/Z04/Z05 files**
- **Z03/Z04/Z05 exist but not included in dev log**
- **Not asking about PR creation with AskUserQuestion**
- **Asking "would you like me to..." in prose instead of tool**

## Common Rationalizations

| Excuse | Reality |
|--------|---------|
| **"Tests pass locally, skip verification"** | **NO.** Run tests NOW. Verify before documenting. |
| **"Just Z01/Z02 need cleanup"** | **NO.** Remove ALL Z01-Z05 files. PR workflow creates Z03/Z04/Z05. |
| **"Hardcode docs/ai/ongoing path"** | **NO.** Detect pattern. Different repos use different structures. |
| **"Skip checking for Z03/Z04/Z05"** | **NO.** Check and include if they exist. PR workflow creates them. |
| **"User obviously wants PR, no need to ask"** | **NO.** Use AskUserQuestion. User might want manual control. |
| "Dev log is documentation, skip TodoWrite" | **NO.** 7 steps with cleanup = MUST track. |
| "Implementation is simple, skip docs update" | **NO.** Check README/CHANGELOG. Feature needs docs. |
| "I'll suggest next steps in prose" | **NO.** Use AskUserQuestion tool for PR creation. |

## Success Criteria

You followed the workflow if:
- ✓ Tests passed before creating dev log
- ✓ Found Z01/Z02 files and detected paths
- ✓ Created timestamped dev log with all sections
- ✓ Checked for Z03/Z04/Z05 and included if present
- ✓ Updated README/docs if needed
- ✓ Removed ALL Z01-Z05 files (not just Z01/Z02)
- ✓ Verified no Z0*.md files remain
- ✓ Generated PR description
- ✓ Used AskUserQuestion for PR creation (not prose)
- ✓ Created PR if user chose Yes
