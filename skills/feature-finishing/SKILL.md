---
name: feature-finishing
description: Use after feature-implementing completes - performs final quality check from fresh context
---

# Feature Workflow: Finish Feature

## YOU ARE READING THIS SKILL RIGHT NOW

**STOP. Before doing ANYTHING else:**

1. Create a progress plan (see below)
2. Mark Step 1 as `in_progress`
3. Confirm you are on a feature branch, not `main`

**This skill must run from fresh context. If you still rely on the feature-implement conversation history, restart and review the branch with fresh eyes.**

## MANDATORY FIRST ACTION: Create Progress Plan

```typescript
update_plan({
  "explanation": "Tracking feature finishing workflow",
  "plan": [
    {"step": "Step 1: Confirm collaboration mode and decision fallback path", "status": "in_progress"},
    {"step": "Step 2: Get current branch and changed files", "status": "pending"},
    {"step": "Step 3: Read AGENTS.md first and CLAUDE.md if it exists", "status": "pending"},
    {"step": "Step 4: Load Z01 and Z02 workflow files", "status": "pending"},
    {"step": "Step 5: Hunt for bugs with an adversarial pass", "status": "pending"},
    {"step": "Step 6: Compare implementation against the plan", "status": "pending"},
    {"step": "Step 7: Run a PR-style review pass", "status": "pending"},
    {"step": "Step 8: Run a security-focused review pass", "status": "pending"},
    {"step": "Step 9: Present findings and collect a user decision", "status": "pending"},
    {"step": "Step 10: Execute the chosen follow-up path", "status": "pending"},
    {"step": "Step 11: Create Z05 finish documentation", "status": "pending"}
  ]
})
```

**After each step:** Mark completed and move `in_progress` to the next step.

## Workflow Steps

### Step 1: Confirm Collaboration Mode

This workflow can run in Default mode or Plan mode.

Decision handling rules:
1. Use `request_user_input` when available.
2. Otherwise use strict prose choices and accept only explicit numeric or exact-label responses.

---

### Step 2: Get Current Branch and Changed Files

Run:

```bash
git branch --show-current
git diff main --name-only
```

Extract:
- current branch name
- list of changed files

If the current branch is `main`, stop and report: `Cannot run feature-finishing from main. Switch to the feature branch first.`

---

### Step 3: Read Project Instructions

Read `AGENTS.md` first. Then read `CLAUDE.md` if it exists.

Extract:
- required patterns
- forbidden approaches
- repository-specific quality standards

---

### Step 4: Load Z01 and Z02 Workflow Files

Find workflow planning artifacts in common locations:
- `docs/ai/ongoing/`
- `.ai/ongoing/`
- `docs/ongoing/`

Rules:
- Default to `docs/ai/ongoing/` for this repository when no alternate ongoing location is already in use.
- Read `Z01_{feature}_research.md` and `Z02_{feature}_plan.md` when they exist.
- If `Z02_CLARIFY_{feature}_plan.md` exists and contains answered planning context, read the incorporated answers as needed.

Extract:
- feature name from `Z02_{feature}_plan.md` when available
- original requirements from `Z01`
- planned execution contract from `Z02`
- `ONGOING_DIR` for the eventual `Z05` artifact

If no plan files are found:
- note `No plan found`
- continue the quality check against the branch diff alone

---

### Step 5: Hunt for Bugs With an Adversarial Pass

Assume defects exist. Attack the change.

Hunt for:
- security issues
- logic errors
- edge-case gaps
- missing or weak tests
- violations of `AGENTS.md` or `CLAUDE.md`

For each finding, record:
- file and line range
- severity
- type
- why it is a real issue
- how to trigger or observe it

---

### Step 6: Compare Implementation Against the Plan

If `Z02` exists, compare the implementation to the planned behavior.

Track:
- intentional deviations
- accidental deviations
- missing planned work
- extra work that may need explanation

If there is no `Z02`, note that this was an ad-hoc implementation.

---

### Step 7: Run a PR-Style Review Pass

Review the branch diff as if you were an external reviewer.

Goal:
- catch naming, layering, consistency, and test-quality issues likely to be raised in PR review

How:
- re-read `git diff main`
- focus on reviewer-visible issues rather than only runtime failures
- merge and de-duplicate findings from earlier steps

---

### Step 8: Run a Security-Focused Review Pass

Review the branch diff as if you were an AppSec reviewer.

Goal:
- surface vulnerabilities before PR feedback

How:
- trace trust boundaries
- check validation and encoding
- look for privilege or data exposure issues
- document exploitability and impact

Merge and de-duplicate findings from prior steps.

---

### Step 9: Present Findings and Collect a Decision

Show the aggregate summary first, then the full numbered findings index before any issue-by-issue loop begins.

Required format:

```markdown
## Feature Finish Assessment: {Feature Name}

**Branch**: {branch}
**Files Changed**: {count}
**Plan Status**: Found Z01/Z02 | No plan found

### Findings Summary
- Critical: {count}
- High: {count}
- Medium: {count}
- Low: {count}

### Issues by Type
- Security: {count}
- Bugs: {count}
- Code Quality: {count}
- Tests: {count}
- Plan Deviations: {count}

### Critical Issues
1. {description} ({file}:{line})

### Findings Index
1. {Issue Type} - {Description} ({Severity}) [{file}:{line-start}-{line-end}]
2. ...
```

If there are zero findings, print `Findings Index: None`.

Then ask how to proceed.

Preferred structured input:
```typescript
request_user_input({
  questions: [{
    question: "How would you like to handle these findings?",
    header: "Action",
    options: [
      {label: "Fix all", description: "Apply fixes for all actionable issues"},
      {label: "Loop issues", description: "Decide one issue at a time"},
      {label: "Document only", description: "Create Z05 without making code changes"}
    ]
  }]
})
```

Strict prose fallback:
- `How would you like to handle these findings? Reply with 1, 2, or 3.`
- `1) Fix all`
- `2) Loop issues`
- `3) Document only`

Do not execute fixes before the user chooses.

---

### Step 10: Execute the Chosen Follow-Up Path

**If the user chooses `Fix all`:**
- invoke `superpowers:systematic-debugging` with the full findings set
- fix the issues
- run the relevant verification commands

**If the user chooses `Loop issues`:**
- confirm the findings index from Step 9 is already on screen
- present one issue at a time
- after each issue, ask immediately and stop output after the question

Preferred structured input for each issue:
```typescript
request_user_input({
  questions: [{
    question: "How should I handle Issue {n}?",
    header: "Issue {n}",
    options: [
      {label: "Fix issue", description: "Apply a fix now"},
      {label: "Skip issue", description: "Leave it unfixed and continue"},
      {label: "Explain issue", description: "Provide more context before deciding"},
      {label: "Stop cycle", description: "Stop the issue loop and continue to documentation"}
    ]
  }]
})
```

Strict prose fallback:
- `How should I handle Issue {n}? Reply with 1, 2, 3, or 4.`
- `1) Fix issue`
- `2) Skip issue`
- `3) Explain issue`
- `4) Stop cycle`

Rules:
- one pending issue decision at a time
- do not move to the next issue before the current issue has an explicit decision
- if the user chooses `Fix issue`, invoke `superpowers:systematic-debugging` for that issue before making code changes
- if the user chooses `Explain issue`, update the assessment with the new context and ask again

**If the user chooses `Document only`:**
- skip straight to Step 11

---

### Step 11: Create Z05 Finish Documentation

Always create `Z05`, regardless of whether fixes were applied.

**Location:** `{ONGOING_DIR}/Z05_{feature}_finish.md`

If `Z02` exists, use its `snake_case` feature slug.
If no `Z02` exists, derive the feature name from the branch or ask when needed.

Format:

```markdown
# Feature Finish: {Feature Name}

**Date**: {date}
**Branch**: {branch}
**Files Changed**: {count}
**Plan Status**: Found | Not Found

## Findings

### Issue 1: {Type} - {Description}
- **File**: {file}:{line}
- **Severity**: {severity}
- **Description**: {explanation}
- **Plan Deviation**: Yes | No
- **User Context**: {if provided}
- **Action**: Fixed | Skipped | Explained
- **Status**: Applied | Skipped | Context only

## Summary
- Total: {count}
- Fixed: {count}
- By severity: Critical {count}, High {count}, Medium {count}, Low {count}
- By type: Security {count}, Bugs {count}, Code Quality {count}, Tests {count}, Plan Deviations {count}

## Plan Deviations
{intentional vs unintentional}

## Recommendations
{follow-up actions}
```

If implementation deviated from plan, ask whether the user wants `Z01` or `Z02` updated to reflect the actual outcome.

## Red Flags

- Ran this workflow from `main`
- Reused feature-implement context instead of reviewing from fresh context
- Skipped `AGENTS.md` or `CLAUDE.md`
- Skipped the PR-style or security review passes
- Started fixing before asking the user how to proceed
- Used direct edits for a fix path that should have gone through `superpowers:systematic-debugging`
- Moved through the issue loop with more than one pending decision at once

## Success Criteria

- Ran from fresh context on a feature branch
- Loaded repo instructions and workflow artifacts when available
- Performed adversarial, PR-style, and security-focused review passes
- Presented a full findings index before any issue-by-issue loop
- Used structured input when available and strict prose fallback otherwise
- Routed fixes through `superpowers:systematic-debugging`
- Created `Z05_{feature}_finish.md` with the final assessment and actions taken
