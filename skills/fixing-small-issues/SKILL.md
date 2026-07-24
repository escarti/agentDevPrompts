---
name: fixing-small-issues
description: Use when fixing a bounded bug, hotfix, regression, failing test, error, observed misbehavior, or small corrective change. Do not use for new features or capability gaps.
---

# Fixing Small Issues

## Mandatory First Action: Create the Coordinator Plan

Before launch, create:

```text
Step 0: Load instructions, resolve source, and create/resume bugfix branch
Step 1: Initialize phase_1_attempts=0 and phase_2_attempts=0
Step 2: Run and validate Phase 1
Step 3: Post accepted diagnosis comment when an issue exists
Step 4: Run and validate Phase 2
Step 5: Keep or revert the returned commit
Step 6: Loop, block, or complete
```

Add no other stages. Use `feature-workflow:use-sub-agent`. Agents are fresh, sequential, single-phase. Inspect every log for completion/final checkpoint before trust. Retain checkpoints/counters; load the complete exploratory log only if its checkpoint is missing, malformed, contradictory, or untrustworthy.

## Scope and Iron Laws

Features/gaps route to `feature-workflow:feature-researching`. Product ambiguity, broad refactoring, contracts, migrations, security, data-loss, or feature-like scope route to Human Intervention.

NO FOURTH SPAWN OF EITHER PHASE

No Z artifacts, tracker/phased plans, batch approvals, or feature-QA/multi-profile pipeline. Never reset/rewrite attempts. Push, PR, merge, issue close, labels, or assignment require explicit request; comments follow the contract below.

## Step 0: Load Instructions, Resolve Source, and Create the Branch

Read instructions. Source priority: explicitly supplied GitHub issue; GitHub issue unambiguously identified by task context; direct report. Multiple/ambiguous contextual issues require clarification before branch/comment. For canonical issues, GitHub-read body/comments before branching; unreadable source is an external blocker. Never guess. Direct reports remain in-task; create no tracker.

- Branches: issue `bugfix/<issue-number>_<bug-slug>`; direct `bugfix/<bug-slug>`
- Slug: lowercase snake_case, unsafe characters removed, maximum 50 characters
- Base: `main` unless user-authorized otherwise

Pre-branch: instructions, minimal source resolution, read-only git inspection only. Resume only the exact branch. Detached HEAD, unrelated branch, unclear provenance, or any dirty tree pauses before agents; preserve all user changes.

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

Independent cumulative counters persist across phase switches/resume. Third attempts may succeed. Retry needs new evidence/different approach.

## Step 2: Spawn Phase 1 — Reproduce and Diagnose

Pass only source, branch, constraints, attempt, checkpoint, retry evidence. On-branch, use `superpowers:systematic-debugging`: expected/actual behavior, reproduction/evidence, tested hypotheses, causal root cause, options, success criteria. No production fix/tracked changes; remove instrumentation.

## Step 3: Validate and Publish the Diagnosis Checkpoint

Validate log, exit, and clean `git status --short`. Require:

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

`ready` = evidence-backed root cause, bounded fix, testable criteria, no ambiguity/risk. Feature gap = `Status: escalate`, `Affected scope: feature-gap`; stop before Phase 2, route to `feature-workflow:feature-researching`. `blocked` -> Human Intervention. Auto-comment accepted issue diagnosis.

## Step 4: Spawn Phase 2 — Plan, Fix, Verify, and Commit

Pass diagnosis. On-branch, use `superpowers:test-driven-development`, `superpowers:verification-before-completion`, and a three-to-six-step plan. Write a failing regression first. Use precise manual reproduction only when no existing automated harness can express the regression without disproportionate new infrastructure; record why in `Regression coverage`. Make the smallest root-cause fix; verify original/neighbors; remove residue; commit.

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

`blocked` needs no empty commit. `fixed`/changed `retryable` require an attributable exact-branch commit.

## Step 5: Validate the Resolution Checkpoint and Commit

Validate log/exit status:

1. Confirm expected-branch commit.
2. Inspect scope/residue/unrelated diff.
3. Rerun original/proportionate verification.
4. Keep success.
5. Keep useful partial commit before retry.
6. Reject with `git revert`, never `git reset`.
7. On invalidated diagnosis, revert then Phase 1.

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

On Human Intervention, return:

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

For canonical issues, automatically post in one or two sentences:

- Diagnosis: reproduction + root cause + intended fix
- Resolution: fix + passing verification
- Blocked: exhausted phase/risk + needed decision

Skip retries; correct a superseded diagnosis once. Only comments mutate automatically. Report failure accurately; it does not invalidate a verified fix.

## Completion Contract

Complete after Step 5, resolved risks, and resolution comment/failure report. Report cause, fix, commit, verification, risk.

## Red Flags

Stop on any violated gate.
