---
name: feature-documenting
description: Use when implementation complete and tests pass - follow structured workflow with custom patterns
---

# Feature Workflow: Document Implementation

## YOU ARE READING THIS SKILL RIGHT NOW

**STOP. Before doing ANYTHING else:**

1. ☐ Verify session is running in Plan mode
2. ☐ Create TodoWrite checklist (see below)
3. ☐ Mark Step 0 as `in_progress`
4. ☐ Verify tests pass (don't document if failing)

**This skill consolidates Z01-Z05 files and DELETES them. Make sure implementation is complete.**

## MANDATORY FIRST ACTION: Create TodoWrite

```typescript
TodoWrite({
  todos: [
    {content: "Step 0: Verify Plan mode and stop if unavailable", status: "in_progress", activeForm: "Checking collaboration mode"},
    {content: "Step 1: Verify tests pass", status: "pending", activeForm: "Running tests"},
    {content: "Step 2: Find Z01/Z02 files and detect paths", status: "pending", activeForm: "Finding Z-files"},
    {content: "Step 3: Create dev log with all Z-files", status: "pending", activeForm: "Writing dev log"},
    {content: "Step 4: Update README/docs if needed", status: "pending", activeForm: "Updating docs"},
    {content: "Step 5: Clean up ALL Z01-Z05 files", status: "pending", activeForm: "Removing temp files"},
    {content: "Step 6: Generate PR description", status: "pending", activeForm: "Creating PR description"},
    {content: "Step 7: Check for existing PR and ask next steps", status: "pending", activeForm: "Checking PR status"}
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

### Step 0: Plan Mode Gate (BLOCKING)

This workflow must run in Plan mode.

If current mode is not Plan mode:
1. STOP immediately
2. Do not run documentation steps
3. Report: "feature-documenting requires Plan mode. Please switch to Plan mode and rerun."

---

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

### Step 7: Check for Existing PR and Ask About Next Steps

**First, check if PR already exists:**
```bash
gh pr view --json number,title,url
```

**If PR exists:**

Use Codex-first decision protocol:
```typescript
request_user_input({
  questions: [{
    question: "PR already exists. How should I proceed?",
    header: "Update PR",
    options: [
      {label: "Update existing PR", description: "Commit and push to update the PR"},
      {label: "Manual commit", description: "I'll commit and push manually"}
    ]
  }]
})
```

Fallback order:
1. Use `request_user_input` when available.
2. If `request_user_input` is unavailable and runtime supports `AskUserQuestion`, use `AskUserQuestion`.
3. If neither tool is available, ask in prose with strict choices:
   - `PR already exists. How should I proceed? Reply with 1 or 2.`
   - `1) Update existing PR`
   - `2) Manual commit`
   - Accept only explicit `1|2` (or exact label). If unclear, ask once to clarify.

**If "Update existing PR":**
- Stage the dev log file
- Stage the Z-file deletions
- Stage any documentation updates
- Commit with descriptive message
- Push to remote (updates existing PR automatically)
- Return PR URL

**If "Manual commit":**
- Remind user what needs to be staged and committed

---

**If NO PR exists:**

Use Codex-first decision protocol:
```typescript
request_user_input({
  questions: [{
    question: "Would you like me to create a pull request now?",
    header: "PR Creation",
    options: [
      {label: "Yes", description: "Commit, push, and create PR with gh CLI"},
      {label: "No", description: "I'll create the PR manually"}
    ]
  }]
})
```

Fallback order:
1. Use `request_user_input` when available.
2. If `request_user_input` is unavailable and runtime supports `AskUserQuestion`, use `AskUserQuestion`.
3. If neither tool is available, ask in prose with strict choices:
   - `Would you like me to create a pull request now? Reply with 1 or 2.`
   - `1) Yes`
   - `2) No`
   - Accept only explicit `1|2` (or exact label). If unclear, ask once to clarify.

**If Yes:**
- Stage the dev log file
- Stage the Z-file deletions
- Stage any documentation updates
- Commit with descriptive message
- Push to remote
- Create PR with `gh pr create` using generated description
- Return PR URL

**If No:**
- Confirm completion
- Remind user what needs to be staged and committed:
  - Dev log file
  - Z-file deletions
  - Documentation updates

---

## Red Flags - You're Failing If:

- **Tests failing but creating dev log anyway**
- **Using hardcoded paths instead of detecting pattern**
- **Only removing Z01/Z02 (must remove ALL Z01-Z05)**
- **Not checking for Z03/Z04/Z05 files**
- **Z03/Z04/Z05 exist but not included in dev log**
- **Not checking for existing PR before asking about creation**
- **Ran this skill outside Plan mode**
- **Not asking about PR creation/update with the Codex-first decision protocol**
- **Using free-form prose asks without strict options**
- **Committing without staging dev log and Z-file deletions**
- **Staging only some changes (must stage dev log + deletions + docs)**

## Common Rationalizations

| Excuse | Reality |
|--------|---------|
| **"Tests pass locally, skip verification"** | **NO.** Run tests NOW. Verify before documenting. |
| **"Just Z01/Z02 need cleanup"** | **NO.** Remove ALL Z01-Z05 files. PR workflow creates Z03/Z04/Z05. |
| **"Hardcode docs/ai/ongoing path"** | **NO.** Detect pattern. Different repos use different structures. |
| **"Skip checking for Z03/Z04/Z05"** | **NO.** Check and include if they exist. PR workflow creates them. |
| **"User obviously wants PR, no need to ask"** | **NO.** Ask using the Codex-first decision protocol. User might want manual control. |
| "Dev log is documentation, skip TodoWrite" | **NO.** 7 steps with cleanup = MUST track. |
| "Implementation is simple, skip docs update" | **NO.** Check README/CHANGELOG. Feature needs docs. |
| "I'll suggest next steps in prose" | **NO.** Use the Codex-first decision protocol for PR creation/update. |
| "git commit -a stages everything" | **NO.** Explicitly stage dev log, deletions, and docs. Verify with git status. |

## Success Criteria

You followed the workflow if:
- ✓ Tests passed before creating dev log
- ✓ Verified session was in Plan mode before Step 1
- ✓ Found Z01/Z02 files and detected paths
- ✓ Created timestamped dev log with all sections
- ✓ Checked for Z03/Z04/Z05 and included if present
- ✓ Updated README/docs if needed
- ✓ Removed ALL Z01-Z05 files (not just Z01/Z02)
- ✓ Verified no Z0*.md files remain
- ✓ Generated PR description
- ✓ Checked for existing PR with `gh pr view`
- ✓ Used Codex-first decision protocol for PR creation/update (request_user_input first, AskUserQuestion compatibility fallback, strict prose fallback)
- ✓ Staged dev log, Z-file deletions, and docs before committing
- ✓ Created/updated PR if user chose Yes
