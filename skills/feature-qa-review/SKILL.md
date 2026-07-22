---
name: feature-qa-review
description: Use after feature-implementing completes on a feature branch and before any finishing or publication work begins.
---

# Feature Workflow: QA Review Feature Branch

## YOU ARE READING THIS SKILL RIGHT NOW

**STOP. Before doing ANYTHING else:**

1. Create the progress plan below.
2. Mark Step 1 as `in_progress`.
3. Confirm the current branch is not `main`.
4. Capture the exact commit to review.
5. Rebuild review context from source artifacts before launching subagents.

This is the mandatory independent gate between `feature-implementing` and `feature-finishing`. It may run in the same session as implementation, but it must use fresh source and branch evidence rather than chat memory.

## MANDATORY FIRST ACTION: Create Progress Plan

```typescript
update_plan({
  "explanation": "Tracking feature QA review workflow",
  "plan": [
    {"step": "Step 1: Confirm collaboration mode and review target", "status": "in_progress"},
    {"step": "Step 2: Detect branch, reviewed commit, diff scope, feature slug, and ongoing directory", "status": "pending"},
    {"step": "Step 3: Read AGENTS.md first and CLAUDE.md if it exists", "status": "pending"},
    {"step": "Step 4: Resolve tracker-first or local-artifacts source-of-truth mode", "status": "pending"},
    {"step": "Step 5: Build the shared QA execution brief", "status": "pending"},
    {"step": "Step 6: Launch the five review-profile subagents", "status": "pending"},
    {"step": "Step 7: Synthesize, normalize, and de-duplicate findings", "status": "pending"},
    {"step": "Step 8: Present findings and collect one decision per issue", "status": "pending"},
    {"step": "Step 9: Execute selected finding actions", "status": "pending"},
    {"step": "Step 10: Run fresh verification and determine whether the run is a clean candidate", "status": "pending"},
    {"step": "Step 11: Create Z06 QA gate documentation", "status": "pending"},
    {"step": "Step 12: Ask for PASS acceptance and hand off to feature-finishing", "status": "pending"}
  ]
})
```

After each step, mark it completed and move `in_progress` to the next step.

## Gate Invariant

```text
ANY FINDING IN THIS RUN -> BLOCKED
ANY FAILED OR MISSING REQUIRED VERIFICATION -> BLOCKED
ANY IMPLEMENTATION OR NON-DOCUMENTATION CHANGE AFTER THE REVIEWED COMMIT -> COMPLETE FRESH QA RERUN
PASS WITHOUT EXPLICIT USER ACCEPTANCE -> FINISHING REMAINS BLOCKED
ONLY AN ACCEPTED PASS MAY LAUNCH FEATURE-FINISHING
```

Finding severity and disposition do not weaken this gate. Fixing a finding does not convert the current run to `PASS`; commit the fix and run every QA profile again against the new commit.

## Workflow Steps

### Step 1: Confirm Collaboration Mode and Review Target

This workflow can run in Default mode or Plan mode.

Decision handling rules:
1. Use `request_user_input` when available.
2. Otherwise use strict prose choices and accept only an explicit number or exact label.
3. Do not invent silent defaults after findings or a candidate `PASS` are presented.

Review only the current feature branch against `main`.

If the current branch is `main`, stop and report:

```text
Cannot run feature-qa-review from main. Switch to the feature branch first.
```

### Step 2: Detect Branch, Reviewed Commit, Diff Scope, Feature Slug, and Ongoing Directory

Run:

```bash
git branch --show-current
git rev-parse HEAD
git status --short
git diff main --name-only
git diff main
```

Record the full `git rev-parse HEAD` value as `Reviewed Commit`.

Stop before review if tracked implementation changes are uncommitted. A commit-bound verdict cannot cover uncommitted code. Do not stage or discard unrelated user changes.

Extract:
- current branch
- reviewed commit
- changed-file list
- likely feature slug
- `ONGOING_DIR`

Feature slug discovery order:
1. `Z02_{feature}_plan.md` in the active ongoing directory
2. `Z01_{feature}_research.md` when Z02 is missing
3. normalized current branch suffix

Ongoing directory lookup order:
- the existing workflow artifact directory for the feature
- `docs/ai/ongoing/`
- `.ai/ongoing/`
- `docs/ongoing/`

A branch with no changed files versus `main` is still reviewable and must still produce Z06.

### Step 3: Read Project Instructions

Read in this order:
1. `AGENTS.md`
2. `CLAUDE.md` when it exists
3. `README.md` when it exists
4. `PUBLISHING.md` when release, install, command, plugin, or repository-instruction files changed

Extract repository constraints, verification expectations, workflow artifact rules, and tracker conventions.

Documentation drift is owned by `feature-finishing`. Read documentation here only to understand the implementation contract; do not launch a documentation-consistency review profile.

### Step 4: Resolve Source-of-Truth Mode

Tracker context is authoritative when it exists. Otherwise use local artifacts.

Tracker discovery order:
1. entrypoint explicitly supplied by `feature-implementing` or the user
2. GitHub or Jira references in the active `Z02_*_plan.md`
3. tracker identifiers or URLs in `Z99_implementation_status.md`

Local artifact discovery order:
1. `Z01_{feature}_research.md`
2. `Z02_{feature}_plan.md`
3. `Z02_CLARIFY_{feature}_plan.md` when answers are present
4. `Z99_implementation_status.md`

Use one mode:
- `tracker-first`: tracker requirements are the expected-behavior contract; local files are supporting history.
- `local-artifacts-only`: Z01 and Z02 are the expected-behavior contract; Z99 is execution evidence.
- `diff-only`: no tracker or workflow artifacts exist; review the branch diff and note `No plan or tracker context found`.

### Step 5: Build the Shared QA Execution Brief

Every review subagent receives the same base brief:
- target branch
- comparison target: `main`
- full reviewed commit SHA
- source-of-truth mode
- feature slug and ongoing directory
- changed-file scope
- applicable AGENTS.md and CLAUDE.md constraints
- relevant tracker or local requirements
- required finding schema

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

Allowed severities: `Critical`, `High`, `Medium`, `Low`.

Allowed types: `Security`, `Bug`, `Plan Deviation`, `Tests`, `Code Quality`.

### Step 6: Launch Five Isolated Review Profiles

Use `feature-workflow:use-sub-agent` patterns for launch, timeout, and result inspection.

Launch one isolated subagent per profile:
1. Bug hunter
2. Security reviewer
3. Plan-conformance reviewer
4. Test-gap reviewer
5. Maintainability / reviewer-likelihood reviewer

Rules:
- give each subagent the shared brief plus only its profile mission
- do not leak conclusions between profiles
- keep review scope tied to the reviewed commit and comparison diff
- require exactly `No findings` or findings in the required schema
- inspect every subagent result before trusting it
- treat missing, timed-out, malformed, or uninspected output as a failed profile, not `No findings`

Profile missions:
- Bug hunter: runtime behavior, edge cases, and broken assumptions
- Security reviewer: trust boundaries, exposure, validation, and exploitability
- Plan-conformance reviewer: implementation versus tracker or local contract
- Test-gap reviewer: weak, missing, or misleading verification coverage
- Maintainability reviewer: naming, layering, consistency, and likely review friction

### Step 7: Synthesize Findings

Merge all outputs into one canonical set.

Rules:
- normalize types and severities to the Step 5 taxonomy
- de-duplicate overlaps while preserving `reported_by`
- keep the strongest concrete rationale and reproduction details
- tie findings to exact files and tight line ranges when possible
- use the higher severity when profiles disagree and preserve provenance

If every profile returns `No findings`, continue to Step 10. Otherwise continue to Step 8 and set the eventual verdict to `BLOCKED`.

### Step 8: Present Findings and Collect Decisions

Show the aggregate summary and complete numbered index before presenting any individual finding.

```markdown
## Feature QA Review: {Feature Name}

**Branch**: {branch}
**Reviewed Commit**: {full SHA}
**Source of Truth**: {tracker-first | local-artifacts-only | diff-only}
**Files Changed**: {count}
**Review Profiles**: bug hunter, security, plan-conformance, test-gap, maintainability

### Findings Summary
- Critical: {count}
- High: {count}
- Medium: {count}
- Low: {count}

### Findings Index
1. {Type} - {Description} ({Severity}) [{file}:{line-start}-{line-end}] {reported_by}
```

Then handle one finding at a time. Preferred structured choices:

1. `Fix and rerun QA` — fix this issue, commit it, and keep this run blocked.
2. `Record follow-up` — leave code unchanged and keep this run blocked.
3. `Stop` — stop the loop and keep this run blocked.

If the user asks for explanation, provide it and ask about the same finding again.

Do not mutate code or trackers while collecting decisions.

### Step 9: Execute Finding Actions

For `Fix and rerun QA`:
1. Invoke `superpowers:systematic-debugging` before editing.
2. Apply the smallest safe fix.
3. Run targeted verification.
4. Commit the fix on the feature branch.
5. Record that a complete fresh QA run is required.

For `Record follow-up`:
- create the smallest tracker follow-up only when the target and mutation tools are unambiguous
- otherwise write a ready-to-file follow-up into Z06

If the loop stops, mark remaining findings `Undecided`.

Regardless of actions, any finding discovered in this run fixes the final verdict at `BLOCKED`. Do not rerun only the reporting profile and do not continue to finishing.

### Step 10: Run Fresh Verification and Determine the Clean Candidate State

Run fresh verification against the reviewed commit:
- always run `git diff --check`
- run verification commands required by the tracker, Z02, AGENTS.md, or project tooling
- inspect full output and exit status

Set `Clean Candidate: Yes` only when:

- all five profiles returned `No findings`
- every result was inspected
- all required verification passed
- HEAD still equals `Reviewed Commit`
- no uncommitted implementation changes appeared during review

Otherwise set `Clean Candidate: No`.

The persisted verdict remains `BLOCKED` until a clean candidate is explicitly accepted in Step 12. A clean candidate is not yet a final `PASS`.

### Step 11: Create Z06 QA Gate Documentation

Always create `{ONGOING_DIR}/Z06_{feature}_qa_review.md`.

Required header:

```markdown
# Feature QA Review: {Feature Name}

**Date**: {date}
**Branch**: {branch}
**Reviewed Commit**: {full SHA}
**Source of Truth**: {tracker-first | local-artifacts-only | diff-only}
**Clean Candidate**: Yes | No
**Verdict**: BLOCKED
**User Acceptance**: Not accepted
**Review Profiles**: bug hunter, security, plan-conformance, test-gap, maintainability
**Files Changed**: {count}
**Verification**: {commands and outcomes}
```

Then include:
- finding counts by severity and type
- every finding and its decision/disposition
- failed or missing profile results
- unresolved recommendations
- explicit rerun requirement when `Clean Candidate` is `No`

### Step 12: Accept PASS and Hand Off to Finishing

If `Clean Candidate` is `No`:
- do not ask to proceed to finishing
- do not invoke or suggest finishing as an alternative
- report the blocker and the requirement for a complete fresh QA run

If `Clean Candidate` is `Yes`, present the reviewed commit and verification summary, then ask:

```text
QA produced a clean candidate for {reviewed commit}. Accept it as PASS and continue to feature-finishing?
1) Accept and continue
2) Do not accept
```

Only after explicit `Accept and continue`:
1. Update Z06 to `**Verdict**: PASS` and `**User Acceptance**: Accepted`.
2. Invoke `feature-workflow:feature-finishing` with the Z06 path, branch, reviewed commit, feature slug, and ongoing directory.

If the user does not accept, leave Z06 as `Verdict: BLOCKED` and `User Acceptance: Not accepted`, then stop. Finishing remains blocked.

## Red Flags

- Ran from `main`
- Reviewed uncommitted implementation changes
- Failed to bind the run to a full commit SHA
- Used chat memory instead of source artifacts
- Ignored authoritative tracker context
- Launched fewer or more than the five defined profiles
- Kept documentation consistency as a QA profile
- Trusted missing, malformed, or uninspected subagent output
- Issued `PASS` after any finding existed in the run
- Issued `PASS` with failed or missing verification
- Issued `PASS` before explicit user acceptance
- Reused a prior profile result after code changed
- Treated a fix as permission to skip the complete fresh QA rerun
- Launched finishing without explicit user acceptance
- Skipped Z06

## Common Rationalizations

| Excuse | Reality |
|--------|---------|
| "The finding was fixed, so this run can pass." | No. The reviewed commit changed; commit the fix and rerun all five profiles. |
| "Only the profile that found the issue needs to rerun." | No. Code changes can affect every concern; the complete QA review must be fresh. |
| "A Low finding can be documented and still pass." | No. Any finding makes this run `BLOCKED`, regardless of severity or disposition. |
| "Implementation tests already passed." | Implementation verification does not replace independent QA profiles and fresh QA verification. |
| "The user asked to move quickly, so acceptance is implied." | No. Finishing requires explicit acceptance of the commit-bound `PASS`. |
| "Finishing can check documentation while QA runs." | No. Finishing starts only after an accepted `PASS`. |

## Success Criteria

- Reviewed a named feature branch against `main`
- Bound the run to a full reviewed commit SHA
- Loaded repository instructions and the correct source-of-truth contract
- Launched and inspected exactly five isolated review profiles
- Produced a normalized findings set with provenance
- Made any finding fix the verdict at `BLOCKED`
- Ran fresh required verification
- Created Z06 with verdict, reviewed commit, user acceptance, verification, and dispositions
- Kept a clean candidate `BLOCKED` until explicit acceptance atomically changed it to `PASS`
- Required a complete fresh QA rerun after any implementation/non-documentation change or finding
- Invoked `feature-finishing` only after a clean `PASS` was explicitly accepted
