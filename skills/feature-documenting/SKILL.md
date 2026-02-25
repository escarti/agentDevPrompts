---
name: feature-documenting
description: Use when implementation complete and tests pass - follow structured workflow with custom patterns
---

# Feature Workflow: Document Implementation

## YOU ARE READING THIS SKILL RIGHT NOW

**STOP. Before doing ANYTHING else:**

1. ☐ Confirm collaboration mode (Default or Plan) and continue
2. ☐ Create TodoWrite checklist (see below)
3. ☐ Mark Step 0 as `in_progress`
4. ☐ Verify tests pass (don't document if failing)

**This skill consolidates all workflow `Z*.md` files and DELETES them. Make sure implementation is complete.**

## MANDATORY FIRST ACTION: Create TodoWrite

```typescript
TodoWrite({
  todos: [
    {content: "Step 0: Confirm collaboration mode and decision fallback path", status: "in_progress", activeForm: "Checking collaboration mode"},
    {content: "Step 1: Verify tests pass", status: "pending", activeForm: "Running tests"},
    {content: "Step 2: Find all Z*.md files and detect paths", status: "pending", activeForm: "Finding Z-files"},
    {content: "Step 3: Create dev log with all Z-files", status: "pending", activeForm: "Writing dev log"},
    {content: "Step 4: Update README/docs if needed", status: "pending", activeForm: "Updating docs"},
    {content: "Step 5: Clean up ALL Z*.md files", status: "pending", activeForm: "Removing temp files"},
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
- No workflow `Z*.md` files exist
- Already have dev log for this feature
- PR already merged (unless creating retrospective)

## Workflow Steps

### Step 0: Collaboration Mode Check

This workflow can run in both Default and Plan modes.

Decision collection should be mode-compatible:
1. Use `request_user_input` when available
2. If unavailable, use the documented strict-choice prose fallback in Step 7

---

### Step 1: Verify Tests Pass

Run tests:
```bash
pytest  # or npm test, etc.
```

**If tests fail:** Stop. Fix tests first.

---

### Step 2: Find Z-files and Detect Paths

Scan for workflow `Z*.md` files in common locations:
- docs/ai/ongoing
- .ai/ongoing
- docs/ongoing

**Find feature name** from Z02 filename when available: `Z02_{feature}_plan.md`
If Z02 is missing, infer feature name from remaining Z-file naming and confirm before writing the dev log.

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

## Additional Workflow Artifacts
[Merge every other `Z*.md` file not already covered above, with filename headers]

## Deployment Notes
- Environment variables
- Configuration changes
- Migration steps

## Next Steps
- Follow-up work
- Technical debt
- Future improvements
```

**Check all workflow files and merge all of them:**
```bash
ls {ONGOING_DIR}/Z*.md 2>/dev/null
```

Include every `Z*.md` file in the dev log, even if it does not match Z01-Z05 naming.

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
rm {ONGOING_DIR}/Z*.md 2>/dev/null || true

# Verify cleanup
ls {ONGOING_DIR}/Z*.md 2>/dev/null || echo "✓ All Z-files cleaned up"
```

**This deletes all workflow artifacts matching `Z*.md` (for example Z01-Z05, Z99, and other ZXX variants).**

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
- **Only removing some Z-files instead of ALL `Z*.md`**
- **Not checking all `Z*.md` files in ONGOING_DIR**
- **Some `Z*.md` files exist but are not merged into the dev log**
- **Not checking for existing PR before asking about creation**
- **Not asking about PR creation/update with the Codex-first decision protocol**
- **Using free-form prose asks without strict options**
- **Committing without staging dev log and Z-file deletions**
- **Staging only some changes (must stage dev log + deletions + docs)**

## Common Rationalizations

| Excuse | Reality |
|--------|---------|
| **"Tests pass locally, skip verification"** | **NO.** Run tests NOW. Verify before documenting. |
| **"Just Z01/Z02 need cleanup"** | **NO.** Remove ALL `Z*.md` workflow files, not only selected phases. |
| **"Hardcode docs/ai/ongoing path"** | **NO.** Detect pattern. Different repos use different structures. |
| **"Skip checking some ZXX files"** | **NO.** Check and merge every `Z*.md` file that exists. |
| **"User obviously wants PR, no need to ask"** | **NO.** Ask using the Codex-first decision protocol. User might want manual control. |
| "Dev log is documentation, skip TodoWrite" | **NO.** 7 steps with cleanup = MUST track. |
| "Implementation is simple, skip docs update" | **NO.** Check README/CHANGELOG. Feature needs docs. |
| "I'll suggest next steps in prose" | **NO.** Use the Codex-first decision protocol for PR creation/update. |
| "git commit -a stages everything" | **NO.** Explicitly stage dev log, deletions, and docs. Verify with git status. |

## Success Criteria

You followed the workflow if:
- ✓ Tests passed before creating dev log
- ✓ Confirmed collaboration mode and used mode-compatible decision flow in Step 7
- ✓ Found workflow `Z*.md` files and detected paths
- ✓ Created timestamped dev log with all sections
- ✓ Merged every `Z*.md` file into the dev log (including non-standard ZXX variants)
- ✓ Updated README/docs if needed
- ✓ Removed ALL `Z*.md` files (not just selected phases)
- ✓ Verified no `Z*.md` files remain
- ✓ Generated PR description
- ✓ Checked for existing PR with `gh pr view`
- ✓ Used Codex-first decision protocol for PR creation/update (request_user_input first, AskUserQuestion compatibility fallback, strict prose fallback)
- ✓ Staged dev log, Z-file deletions, and docs before committing
- ✓ Created/updated PR if user chose Yes
