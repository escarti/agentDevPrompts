---
name: fixing-small-issues
description: Use when fixing a bounded bug, hotfix, regression, failing test, error, observed misbehavior, or small corrective change. Do not use for new features or capability gaps.
---

# Fixing Small Issues

## Mandatory First Action: Create the Coordinator Plan

Create the coordinator plan before agent launch:

```text
Step 0: Load instructions, resolve source, and create/resume bugfix branch
Step 1: Initialize phase_1_attempts=0 and phase_2_attempts=0
Step 2: Run and validate Phase 1
Step 3: Post accepted diagnosis comment when an issue exists
Step 4: Run and validate Phase 2
Step 5: Keep or revert the returned commit
Step 6: Loop, block, or complete
```

Do not add feature-workflow stages. **REQUIRED SUB-SKILL:** Use `feature-workflow:use-sub-agent` for launch, timeout, exit status, and logs. Attempts are fresh, sequential, and phase-bounded.

Inspect every log for completion and final checkpoint before trust. Retain only checkpoints/counters; load the complete exploratory log into coordinator context only if its checkpoint is missing, malformed, contradictory, or untrustworthy.

## Scope and Iron Laws

Route new features and capability gaps to `feature-workflow:feature-researching`; pause for product ambiguity, broad refactoring, contracts, migrations, security, data-loss risk, or feature-like scope.

NO PHASE 1 BEFORE THE BUGFIX BRANCH EXISTS
NO FIX WITHOUT AN EVIDENCE-BACKED ROOT CAUSE
NO PHASE 2 WORKSPACE CHANGE WITHOUT AN ATTRIBUTABLE COMMIT
NO SUCCESS CLAIM WITHOUT INDEPENDENT FRESH VERIFICATION
NO FOURTH SPAWN OF EITHER PHASE
NO RESET OR HISTORY REWRITE TO DISCARD A FAILED ATTEMPT
NO Z-ARTIFACT OR FEATURE-QA PIPELINE FOR THIS WORKFLOW

Do not create tracker graphs, phased PR plans, batch approvals, or multi-profile QA.

## Step 0: Load Instructions, Resolve Source, and Create the Branch

Read repository instructions. Source priority: explicit GitHub issue; contextual issue; direct report. For an issue, read body and relevant comments with connected GitHub tools before branching. If unreadable, request the source as an external blocker; never guess. Direct reports need no tracker.

Create or resume:

- Issue: `bugfix/<issue-number>_<bug-slug>`
- Direct report: `bugfix/<bug-slug>`
- Slug: lowercase snake_case, unsafe branch characters removed, maximum 50 characters
- Default base: `main`, unless the user authorizes another

Pre-branch actions: instruction loading, minimal source resolution, git safety inspection. Resume only the exact inferred branch. Detached HEAD, unrelated branch, unclear provenance, or unrelated dirty changes require pause; preserve user changes.

## Step 1: Initialize Attempt State

```text
phase_1_attempts = 0
phase_2_attempts = 0

before spawning phase N:
  if phase_N_attempts >= 3:
    create Human Intervention Checkpoint and stop
  phase_N_attempts += 1
  spawn a fresh phase N agent
```

Counters are independent and cumulative; phase switches do not reset them and task resume preserves them. Third attempts may succeed. Retry only with new evidence or a different approach.

## Step 2: Spawn Phase 1 — Reproduce and Diagnose

Pass only source, branch, repository constraints, attempt number, latest accepted checkpoint, and retry evidence. Require on-branch `superpowers:systematic-debugging`: expected/actual behavior, reproduction or deterministic evidence, tested hypotheses, causal chain, fix options, and success criteria. No production fix or tracked changes; remove instrumentation.

## Step 3: Validate and Publish the Diagnosis Checkpoint

Apply the log contract, check exit status, and require clean Phase 1 `git status --short` plus:

```text
Status: ready | retryable | blocked | escalate
Reproduction:
Evidence:
Root cause:
Affected scope:
Fix options:
Recommended fix:
Risk flags:
Phase 2 success criteria:
```

Accept `ready` only for evidence-backed cause, bounded recommendation, testable criteria, and no material ambiguity/risk. New capability: `Status: escalate`, `Affected scope: feature-gap`, stop before Phase 2, route to `feature-workflow:feature-researching`. `blocked` routes to Human Intervention. Automatically comment on accepted issue diagnoses.

## Step 4: Spawn Phase 2 — Plan, Fix, Verify, and Commit

Pass the diagnosis. Require on-branch `superpowers:test-driven-development`, `superpowers:verification-before-completion`, and a three-to-six-step plan. Capture a failing regression when practical or preserve manual reproduction; make the smallest root-cause fix; run original and neighboring verification; remove residue; commit changed work before return.

Require:

```text
Status: fixed | retryable | diagnosis-invalidated | blocked | escalate
Plan executed:
Commit SHA:
Files changed:
Regression coverage:
Original reproduction result:
Verification commands and results:
Residual risks:
```

A blocked agent needs no artificial empty commit. `fixed` and changed `retryable` work require an attributable commit on the exact bugfix branch.

## Step 5: Validate the Resolution Checkpoint and Commit

Apply the log contract and exit-status check, then:

1. Confirm the commit exists on the expected branch.
2. Inspect its diff for scope, residue, and unrelated changes.
3. Rerun the original reproduction and proportionate verification.
4. Keep a successful commit.
5. Keep useful partial progress before a Phase 2 retry.
6. Reject a wrong attempt with `git revert`, never `git reset`.
7. Revert and return to Phase 1 when diagnosis is invalidated.

## Step 6: Route Completion, Retry, Re-Diagnosis, or Human Intervention

```text
Phase 1 ready -> Phase 2
Phase 1 retryable -> Phase 1, subject to the attempt gate
Phase 1 blocked -> Human Intervention
Phase 1 ambiguity/risk/escalate -> Human Intervention
Phase 2 fixed and independently verified -> Complete
Phase 2 retryable with valid diagnosis -> Phase 2, subject to the attempt gate
Phase 2 diagnosis-invalidated -> revert if needed, then Phase 1
Phase 2 blocked -> Human Intervention
Phase 2 ambiguity/risk/escalate -> Human Intervention
```

For any Human Intervention route, return:

```text
Blocked phase:
Phase 1 attempts:
Phase 2 attempts:
Latest accepted diagnosis:
Current branch and commit:
Current diff state:
Latest failed reproduction or verification:
Why autonomous progress stopped:
Recommended human decision:
```

## GitHub Comment Contract

For a canonical issue, automatically post each applicable public comment in one or two sentences:

- Diagnosis: reproduction + root cause + intended fix
- Resolution: implemented fix + passing verification
- Blocked: exhausted phase or material risk + decision needed

Never comment on internal retries. Correct a superseded diagnosis once. Mutate no issue state beyond comments. Report comment failure without invalidating a verified fix.

## Completion Contract

Complete after reproduction, regression/manual verification, and neighboring checks pass; diff is clean/scoped; bugfix commit accepted; risks resolved; resolution comment posted or failure reported. Report cause, fix, commit, verification, residual risk. Push/PR/merge/closure require explicit request.

## Red Flags

Stop on violated laws, untrusted results, or unrelated workspace changes.
