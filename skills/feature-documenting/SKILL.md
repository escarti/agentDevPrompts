---
name: feature-documenting
description: Use when implementation complete and tests pass - follow structured workflow with custom patterns
---

# Feature Workflow: Document Implementation

## YOU ARE READING THIS SKILL RIGHT NOW

**STOP. Before doing ANYTHING else:**

1. Create a progress plan (see below)
2. Mark Step 1 as `in_progress`
3. Verify the implementation is actually ready to document

**This skill consolidates all workflow `Z*.md` files and deletes them after the dev log is created. Do not run it while implementation is still in motion.**

## MANDATORY FIRST ACTION: Create Progress Plan

```typescript
update_plan({
  "explanation": "Tracking feature documentation workflow",
  "plan": [
    {"step": "Step 1: Confirm collaboration mode and decision fallback path", "status": "in_progress"},
    {"step": "Step 2: Verify tests pass", "status": "pending"},
    {"step": "Step 3: Find workflow Z-files and detect paths", "status": "pending"},
    {"step": "Step 4: Create the development log from workflow artifacts", "status": "pending"},
    {"step": "Step 5: Update repository documentation if needed", "status": "pending"},
    {"step": "Step 6: Clean up all workflow Z-files", "status": "pending"},
    {"step": "Step 7: Generate the PR description and decide PR next steps", "status": "pending"}
  ]
})
```

**After each step:** Mark completed and move `in_progress` to the next step.

## When to Use

- Implementation is complete
- Tests pass
- Workflow artifacts exist
- The branch is ready for final documentation and PR handling

## When NOT to Use

- Implementation is incomplete
- Tests are failing
- No workflow `Z*.md` files exist
- A development log for the same feature was already created and cleaned up

## Workflow Steps

### Step 1: Confirm Collaboration Mode

This workflow can run in Default mode or Plan mode.

Decision handling rules:
1. Use `request_user_input` when available.
2. Otherwise use strict prose choices and accept only explicit numeric or exact-label responses.

---

### Step 2: Verify Tests Pass

Run the repository-appropriate verification command before documenting.

Examples:
```bash
pytest
```

```bash
npm test
```

If tests fail, stop and return to implementation. Do not create the dev log yet.

---

### Step 3: Find Workflow Z-Files and Detect Paths

Find all workflow `Z*.md` files in common ongoing locations:
- `docs/ai/ongoing/`
- `.ai/ongoing/`
- `docs/ongoing/`

Rules:
- Default to `docs/ai/ongoing/` for this repository when no existing alternate location is already in use.
- Include every `Z*.md` file in the chosen ongoing directory, not only `Z01` through `Z05`.

Detect:
- `ONGOING_DIR`
- feature name from `Z02_{feature}_plan.md` when available
- development log directory

Development log directory rules:
- Check `AGENTS.md` for repo defaults
- Reuse an existing development-log pattern if one already exists
- Otherwise default to `docs/ai/dev_logs/`

If `Z02` is missing:
- infer the feature name from the remaining `Z*.md` files when possible
- if inference is ambiguous, ask before writing the dev log

---

### Step 4: Create the Development Log

**Location:** `{DEV_LOGS_DIR}/{YYYYMMDD}_{feature}_dev_log.md`

**Timestamp source:** `date +%Y%m%d`

Structure:

```markdown
# {Feature} Development Log

**Date**: {YYYY-MM-DD}
**Status**: Complete

## Summary
One paragraph describing what was built and why.

## Research Phase
[Content from Z01_{feature}_research.md]

### Clarifications Resolved
[Content from Z01_CLARIFY_{feature}_research.md if it exists]

## Planning Phase
[Content from Z02_{feature}_plan.md]

## Implementation
### What Was Done
- Actual changes made
- Files created or modified
- Key decisions

### Deviations from Plan
- What changed
- Why it changed

### Test Results
- Verification commands
- Key scenarios validated

## PR Workflow
### PR Review
[Content from Z03_*_review.md if it exists]

### PR Fixes
[Content from Z04_*_fix.md if it exists]

### Quality Check
[Content from Z05_*_finish.md if it exists]

## Additional Workflow Artifacts
[Every other Z*.md file not already covered above, grouped by filename]

## Deployment Notes
- Environment variables
- Configuration changes
- Migration steps

## Next Steps
- Follow-up work
- Technical debt
- Future improvements
```

Rules:
- Merge every `Z*.md` file in `ONGOING_DIR` into the dev log, including non-standard `ZXX` variants.
- Preserve enough context that the dev log stands alone after the temporary files are deleted.

---

### Step 5: Update Repository Documentation If Needed

Check whether the implementation requires updates to:
- `README.md`
- `CHANGELOG.md`
- API or usage documentation

Only update files that truly need changes.

---

### Step 6: Clean Up All Workflow Z-Files

Delete every workflow artifact matching `Z*.md` in `ONGOING_DIR`.

Example:
```bash
rm {ONGOING_DIR}/Z*.md
```

Then verify cleanup:
```bash
ls {ONGOING_DIR}/Z*.md
```

Success means no workflow `Z*.md` files remain in that directory.

---

### Step 7: Generate the PR Description and Decide PR Next Steps

Generate a PR description in this format:

```markdown
## Summary
One sentence describing what the PR does.

## Changes
- Key change 1
- Key change 2
- Key change 3

## Testing
- Verification approach
- Coverage or scenario summary

## Deployment Notes
- Environment variables, if any
- Migration steps, if any
```

Then check whether a PR already exists:

```bash
gh pr view --json number,title,url
```

**If a PR exists**, ask:

Preferred structured input:
```typescript
request_user_input({
  questions: [{
    question: "PR already exists. How should I proceed?",
    header: "Update PR",
    options: [
      {label: "Update existing PR", description: "Commit and push to update the PR"},
      {label: "Manual commit", description: "I will commit and push manually"}
    ]
  }]
})
```

Strict prose fallback:
- `PR already exists. How should I proceed? Reply with 1 or 2.`
- `1) Update existing PR`
- `2) Manual commit`

If the user chooses `Update existing PR`:
- stage the dev log
- stage the workflow-file deletions
- stage any documentation updates
- commit with a descriptive message
- push to the remote branch
- return the PR URL

If the user chooses `Manual commit`:
- report what must be staged and committed

**If no PR exists**, ask:

Preferred structured input:
```typescript
request_user_input({
  questions: [{
    question: "Would you like me to create a pull request now?",
    header: "PR Creation",
    options: [
      {label: "Yes", description: "Commit, push, and create a PR with gh"},
      {label: "No", description: "I will create the PR manually"}
    ]
  }]
})
```

Strict prose fallback:
- `Would you like me to create a pull request now? Reply with 1 or 2.`
- `1) Yes`
- `2) No`

If the user chooses `Yes`:
- stage the dev log
- stage the workflow-file deletions
- stage any documentation updates
- commit with a descriptive message
- push to the remote branch
- create the PR with `gh pr create` using the generated description
- return the PR URL

If the user chooses `No`:
- confirm the documentation workflow is complete
- report what still needs to be staged and committed

## Red Flags

- Tests were failing but the dev log was created anyway
- Only some workflow files were merged into the dev log
- Only some `Z*.md` files were deleted
- Paths were hardcoded instead of detected from repo context
- PR creation or update was assumed instead of asked
- Commits were made without staging the dev log, workflow cleanup, and required doc updates together

## Success Criteria

- Verified tests before documenting
- Detected `ONGOING_DIR` and development-log paths correctly
- Created a standalone development log covering every workflow `Z*.md` file
- Updated repository documentation only where needed
- Deleted all temporary workflow `Z*.md` files and verified cleanup
- Generated a reusable PR description
- Asked the user how to handle PR creation or PR updates using structured input when available and strict prose fallback otherwise
