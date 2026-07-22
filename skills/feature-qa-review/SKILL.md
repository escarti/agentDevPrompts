---
name: feature-qa-review
description: Use after feature-implementing to run a tracker-aware, multi-profile QA review on the current feature branch, synthesize subagent findings, and drive an issue-by-issue decision loop with optional fix, documentation, or tracker follow-up actions.
---

# Feature Workflow: QA Review Feature Branch

## YOU ARE READING THIS SKILL RIGHT NOW

**STOP. Before doing ANYTHING else:**

1. Create a progress plan (see below)
2. Mark Step 1 as `in_progress`
3. Confirm you are on a non-`main` feature branch
4. Gather source-of-truth context before launching any review subagent

**This workflow may run in the same session as implementation. Do not require fresh context, but do rebuild review context from source artifacts instead of trusting chat memory.**

## MANDATORY FIRST ACTION: Create Progress Plan

```typescript
update_plan({
  "explanation": "Tracking feature QA review workflow",
  "plan": [
    {"step": "Step 1: Confirm collaboration mode and review target", "status": "in_progress"},
    {"step": "Step 2: Detect branch, diff scope, feature slug, and ongoing directory", "status": "pending"},
    {"step": "Step 3: Read AGENTS.md first and CLAUDE.md if it exists", "status": "pending"},
    {"step": "Step 4: Resolve tracker-first or local-artifacts source-of-truth mode", "status": "pending"},
    {"step": "Step 5: Build the shared QA execution brief", "status": "pending"},
    {"step": "Step 6: Launch the review-profile subagents", "status": "pending"},
    {"step": "Step 7: Synthesize, normalize, and de-duplicate findings", "status": "pending"},
    {"step": "Step 8: Present findings and collect one decision per issue", "status": "pending"},
    {"step": "Step 9: Execute queued fix, documentation, or tracker follow-up actions", "status": "pending"},
    {"step": "Step 10: Create Z06 QA review documentation", "status": "pending"}
  ]
})
```

**After each step:** Mark completed and move `in_progress` to the next step.

## Workflow Steps

### Step 1: Confirm Collaboration Mode and Review Target

This workflow can run in Default mode or Plan mode.

Decision handling rules:
1. Use `request_user_input` when available.
2. Otherwise use strict prose choices and accept only explicit numeric or exact-label responses.
3. Do not invent silent default decisions once the issue loop begins.

Target rules:
- review only the current feature branch in v1
- compare the branch against `main`
- if the current branch is `main`, stop and report: `Cannot run feature-qa-review from main. Switch to the feature branch first.`

---

### Step 2: Detect Branch, Diff Scope, Feature Slug, and Ongoing Directory

Run:

```bash
git branch --show-current
git diff main --name-only
git diff main
```

Extract:
- current branch name
- changed-file list
- likely feature slug
- `ONGOING_DIR`

Feature slug discovery order:
1. `Z02_{feature}_plan.md` in an active ongoing directory
2. `Z01_{feature}_research.md` if `Z02` is missing
3. normalize the current branch suffix into workflow `snake_case`

Ongoing directory lookup order:
- existing workflow artifact directory already in use for the feature
- `docs/ai/ongoing/`
- `.ai/ongoing/`
- `docs/ongoing/`

If no changed files exist versus `main`, continue. A clean diff is a valid QA outcome and should still produce `Z06`.

---

### Step 3: Read Project Instructions

Read in this order:
1. `AGENTS.md`
2. `CLAUDE.md` if it exists
3. `README.md` if it exists
4. `PUBLISHING.md` when release, install, command-surface, plugin, or repo-instruction files changed

Extract:
- repository-specific workflow rules
- command and skill naming expectations
- temporary artifact naming rules
- tracker publication expectations already used by the feature workflow
- documentation surfaces that must stay synchronized when changed together

---

### Step 4: Resolve Tracker-First or Local-Artifacts Source-of-Truth Mode

Tracker is authoritative when tracker context exists. Otherwise local artifacts are authoritative.

Tracker discovery order:
1. tracker entrypoint explicitly provided by the user
2. published GitHub or Jira references embedded in the active `Z02_*_plan.md`
3. tracker identifiers or URLs recorded in `Z99_implementation_status.md`

Local artifact discovery order:
1. `Z01_{feature}_research.md`
2. `Z02_{feature}_plan.md`
3. `Z02_CLARIFY_{feature}_plan.md` when answers are present
4. `Z99_implementation_status.md`

Tracker-mode rules:
- use tracker requirements as the expected-behavior contract
- treat local `Z01` and `Z02` files as supporting implementation history only
- load only the tracker fields needed to understand requirements, phase order, dependencies, and acceptance expectations

Local-artifacts mode rules:
- use `Z01` and `Z02` as the expected-behavior contract
- use `Z99` as execution evidence and completed-task context

If neither tracker context nor local workflow artifacts exist:
- continue in diff-only mode
- note `No plan or tracker context found`

---

### Step 5: Build the Shared QA Execution Brief

Before launching subagents, create one shared execution brief that every review profile receives.

The brief must include:
- target branch
- comparison target: `main`
- source-of-truth mode: `tracker-first`, `local-artifacts-only`, or `diff-only`
- feature slug
- ongoing directory
- changed-file scope
- review constraints from `AGENTS.md` and `CLAUDE.md`
- summary of tracker or local requirements relevant to the branch
- any repo-facing documentation surfaces that may require collateral updates
- required output schema for every finding

Required finding schema:

```text
title
type
severity
file
lines
rationale
repro
suggested_action
reported_by
```

Severity normalization target:
- `Critical`
- `High`
- `Medium`
- `Low`

Type normalization target:
- `Security`
- `Bug`
- `Plan Deviation`
- `Tests`
- `Documentation`
- `Code Quality`

---

### Step 6: Launch the Review-Profile Subagents

Use `feature-workflow:use-sub-agent` patterns for launch, timeout, and log inspection.

Launch one isolated subagent per review profile:
1. Bug hunter
2. Security reviewer
3. Plan-conformance reviewer
4. Test-gap reviewer
5. Maintainability / reviewer-likelihood reviewer
6. Documentation-consistency reviewer

Rules:
- each subagent gets the shared execution brief plus only its profile-specific mission
- do not leak conclusions from one profile into another profile prompt
- keep prompts focused on the branch diff and the resolved source-of-truth contract
- require each subagent to return either `No findings` or a list of findings in the required schema
- inspect every subagent log before trusting the output

Recommended profile missions:
- Bug hunter: attack runtime behavior, edge cases, and broken assumptions
- Security reviewer: trace trust boundaries, exposure risks, validation gaps, and exploitability
- Plan-conformance reviewer: compare implemented behavior to tracker or local contract
- Test-gap reviewer: identify weak, missing, or misleading verification coverage
- Maintainability / reviewer-likelihood reviewer: surface naming, layering, consistency, and review-friction issues
- Documentation-consistency reviewer: check whether changed behavior, repo instructions, install steps, release docs, command surfaces, and workflow artifacts remain synchronized across `AGENTS.md`, `README.md`, `CLAUDE.md`, `PUBLISHING.md`, command wrappers, prompt symlinks, and plugin metadata when any one of those surfaces changes

---

### Step 7: Synthesize, Normalize, and De-Duplicate Findings

Merge all subagent outputs into one canonical findings set.

Rules:
- normalize severities and issue types to the Step 5 taxonomy
- de-duplicate overlapping findings across profiles
- preserve provenance in `reported_by`
- prefer the strongest concrete rationale and repro details when combining duplicates
- keep findings tied to exact files and tight line ranges whenever possible
- if two profiles disagree on severity, keep the higher severity and note the provenance

If every profile returns `No findings`:
- print a zero-findings summary
- skip the per-issue loop
- continue to Step 10

---

### Step 8: Present Findings and Collect One Decision Per Issue

Show the aggregate summary first, then the full numbered findings index before any issue-by-issue loop begins.

Required pre-loop format:

```markdown
## Feature QA Review: {Feature Name}

**Branch**: {branch}
**Source of Truth**: {tracker-first | local-artifacts-only | diff-only}
**Files Changed**: {count}
**Review Profiles**: bug hunter, security, plan-conformance, test-gap, maintainability, documentation-consistency

### Findings Summary
- Critical: {count}
- High: {count}
- Medium: {count}
- Low: {count}

### Issues by Type
- Security: {count}
- Bugs: {count}
- Plan Deviations: {count}
- Tests: {count}
- Documentation: {count}
- Code Quality: {count}

### Findings Index
1. {Issue Type} - {Description} ({Severity}) [{file}:{line-start}-{line-end}] {reported_by}
2. ...
```

If there are zero findings, print `Findings Index: None`.

Then present one finding at a time.

Detailed finding format:

```markdown
## Feature QA Review: {Feature Name}

Finding {n}: {Issue Type} - {Description}
- File: {file}:{line-start}-{line-end}
- Severity: {Critical | High | Medium | Low}
- Reported by: {bug hunter, security reviewer}
- Why this is a real issue: {rationale}
- How to trigger: {repro}
- Suggested action: {suggested_action}
```

Then ask how to handle that one finding.

Preferred structured input:
```typescript
request_user_input({
  questions: [{
    question: "How should I handle Finding {n}?",
    header: "Finding {n}",
    options: [
      {label: "Fix now", description: "Fix this issue immediately in Step 9"},
      {label: "Add to fix queue", description: "Queue this issue for later fixing in Step 9"},
      {label: "Create tracker follow-up", description: "Create or queue a tracker item for this issue in Step 9"},
      {label: "Document only", description: "Record the issue in Z06 without a code or tracker action"},
      {label: "Explain more", description: "Provide more context before deciding"},
      {label: "Stop cycle", description: "Stop the issue loop and continue to execution or documentation"}
    ]
  }]
})
```

Strict prose fallback:
- `How should I handle Finding {n}? Reply with 1, 2, 3, 4, 5, or 6.`
- `1) Fix now`
- `2) Add to fix queue`
- `3) Create tracker follow-up`
- `4) Document only`
- `5) Explain more`
- `6) Stop cycle`

Rules:
- ask about one finding at a time
- stop output after the question
- wait for the explicit decision
- do not move to the next finding before the current one is resolved
- do not fix code or mutate tracker items during Step 8
- if the user chooses `Explain more`, update the explanation and ask again for the same finding

---

### Step 9: Execute Queued Fix, Documentation, or Tracker Follow-Up Actions

After the decision loop finishes:

For each `Fix now` or `Add to fix queue`:
1. Invoke `superpowers:systematic-debugging` before editing code.
2. Apply the smallest safe fix.
3. Run targeted verification for that finding.
4. Record the outcome for `Z06`.

For each `Create tracker follow-up`:
1. Reuse the resolved tracker context if one exists.
2. Create the smallest appropriate follow-up item only when the required tracker tools are available and the target is unambiguous.
3. If tracker mutation is unavailable or ambiguous, record a ready-to-file follow-up entry in `Z06` instead of guessing.

For each `Document only`:
1. Leave the code unchanged.
2. Carry the finding directly into `Z06`.

If the loop stopped early:
- do not auto-handle remaining findings
- mark them as undecided in `Z06`

---

### Step 10: Create Z06 QA Review Documentation

Always create `Z06`, even when there are zero findings.

**Location:** `{ONGOING_DIR}/Z06_{feature}_qa_review.md`

If no feature slug can be derived safely:
- ask the user, or
- fall back to a normalized branch-derived slug

Format:

```markdown
# Feature QA Review: {Feature Name}

**Date**: {date}
**Branch**: {branch}
**Source of Truth**: {tracker-first | local-artifacts-only | diff-only}
**Review Profiles**: bug hunter, security, plan-conformance, test-gap, maintainability, documentation-consistency
**Files Changed**: {count}

## Findings Summary
- Total: {count}
- Critical: {count}
- High: {count}
- Medium: {count}
- Low: {count}
- Security: {count}
- Bugs: {count}
- Plan Deviations: {count}
- Tests: {count}
- Documentation: {count}
- Code Quality: {count}

## Findings

### Finding {n}: {Type} - {Description}
- **File**: {file}:{line}
- **Severity**: {severity}
- **Reported by**: {reported_by}
- **Why this is real**: {rationale}
- **How to trigger**: {repro}
- **Decision**: {Fix now | Add to fix queue | Create tracker follow-up | Document only | Undecided}
- **Disposition**: {Fixed | Queued | Tracker item created | Tracker follow-up drafted | Documented only | Stopped early}
- **Tracker Link or ID**: {optional}

## Unresolved Recommendations
- {remaining follow-up work}
```

## Red Flags

- Started reviewing before creating the progress plan
- Ran on `main`
- Used chat memory as the contract instead of rebuilding context from source artifacts
- Ignored tracker context when it existed
- Launched subagents without a shared execution brief
- Trusted subagent output without inspecting logs
- Presented findings one by one before showing the full findings index
- Fixed code or mutated tracker items during the decision loop
- Skipped `Z06_{feature}_qa_review.md`

## Success Criteria

- Ran on a feature branch against `main`
- Loaded repo instructions and resolved source-of-truth mode correctly
- Launched all six review profiles with isolated prompts
- Produced a normalized, de-duplicated findings set with provenance
- Collected one explicit decision per issue until completion or stop
- Routed any fixes through `superpowers:systematic-debugging`
- Created `Z06_{feature}_qa_review.md` with the final disposition of every finding
