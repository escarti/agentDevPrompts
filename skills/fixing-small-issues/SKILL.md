---
name: fixing-small-issues
description: Use when fixing a bounded bug, hotfix, regression, failing test, error, observed misbehavior, or small corrective change. Do not use for new features or capability gaps.
---

# Fixing Small Issues

## Mandatory First Action: Create the Coordinator Plan

Create and maintain a coordinator plan before launching an agent. Keep only these states; do not add feature-workflow stages:

1. Step 0: Load instructions, resolve source, and create/resume bugfix branch
2. Step 1: Initialize phase_1_attempts=0 and phase_2_attempts=0
3. Step 2: Run and validate Phase 1
4. Step 3: Post accepted diagnosis comment when an issue exists
5. Step 4: Run and validate Phase 2
6. Step 5: Keep or revert the returned commit
7. Step 6: Loop, block, or complete

Use `feature-workflow:use-sub-agent` for agent launch, timeout, log, and exit-status handling. Run one fresh agent per attempt, sequentially; Phase 1 and Phase 2 never run in parallel. Retain only accepted checkpoints and counters in coordinator context. Pass agents only their stated inputs, not prior transcripts or exploratory logs. Agents stop after their assigned phase and never spawn the next attempt.

## Scope and Iron Laws

Use this workflow only for a bounded defect or corrective change. Do not use it for a new feature, an ambiguous product decision, a capability gap, broad refactoring, a migration, security-sensitive work, contract changes, or data-loss risk. Pause for a human decision when scope or risk becomes material.

NO PHASE 1 BEFORE THE BUGFIX BRANCH EXISTS
NO FIX WITHOUT AN EVIDENCE-BACKED ROOT CAUSE
NO PHASE 2 WORKSPACE CHANGE WITHOUT AN ATTRIBUTABLE COMMIT
NO SUCCESS CLAIM WITHOUT INDEPENDENT FRESH VERIFICATION
NO FOURTH SPAWN OF EITHER PHASE
NO RESET OR HISTORY REWRITE TO DISCARD A FAILED ATTEMPT
NO Z-ARTIFACT OR FEATURE-QA PIPELINE FOR THIS WORKFLOW

Do not create local planning artifacts, tracker graphs, phased PR plans, batch approvals, or multi-profile review. Do not push, open a PR, merge, close an issue, change labels, or assign users without an explicit request.

## Step 0: Load Instructions, Resolve Source, and Create the Branch

Read repository instructions first. Resolve the canonical source in this priority order:

1. Explicitly supplied GitHub issue.
2. GitHub issue unambiguously identified by task context.
3. Direct misbehavior report, failing test, error, log, or observed behavior.

When an issue is canonical, use connected GitHub issue tools to read its body and relevant comments before creating the branch. If it cannot be read, do not guess its contents; request the missing source as an external blocker. For a direct report, keep checkpoints in the Codex task and do not force tracker creation.

Derive the branch before investigation:

- Issue branch: `bugfix/<issue-number>_<bug-slug>`
- Direct-report branch: `bugfix/<bug-slug>`
- Bug slug: lowercase snake_case, unsafe branch characters removed, maximum 50 characters
- Default base: `main`

Only read instructions, resolve minimal source identity, and inspect git state before branch creation. New branches start from `main` unless the user explicitly authorizes another base. Resume only when the current branch exactly matches the inferred bugfix branch. Pause before any phase agent on detached HEAD, an unrelated branch, unclear provenance, or unrelated dirty changes. Never discard user changes silently.

## Step 1: Initialize Attempt State

Initialize once per coordinator run:

```text
phase_1_attempts = 0
phase_2_attempts = 0

before spawning phase N:
  if phase_N_attempts >= 3:
    create Human Intervention Checkpoint and stop
  phase_N_attempts += 1
  spawn a fresh phase N agent
```

Counters are independent and cumulative. Switching phases never resets them; resuming the same coordinator task preserves them. A successful third attempt completes normally. A retry requires new failure evidence or a meaningfully different investigation or correction; do not repeat an unchanged failed approach.

## Step 2: Spawn Phase 1 — Reproduce and Diagnose

Use the attempt gate, then instruct a fresh Phase 1 agent to load and follow `superpowers:systematic-debugging`. Require it to remain on the established branch; establish expected and actual behavior; create the smallest practical reproduction or equivalent deterministic evidence; inspect relevant code, tests, history, and nearby patterns; test competing hypotheses; identify the causal chain; compare credible fixes; and define Phase 2 success criteria.

Phase 1 makes no production fix, removes temporary instrumentation, and returns no tracked changes. Pass only the canonical problem source, branch identity, repository constraints, attempt number, the latest accepted checkpoint, and new retry evidence.

## Step 3: Validate and Publish the Diagnosis Checkpoint

After return, check the agent exit status, confirm a complete final checkpoint exists, and verify `git status --short` contains no Phase 1 tracked changes. Load the complete sub-agent log only when the final checkpoint is missing, malformed, contradictory, or untrustworthy.

Require this exact checkpoint:

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

Accept `ready` only when the root cause is evidence-backed, the recommendation is bounded, and the success criteria are testable. Continue to Phase 2 automatically only when no material ambiguity or risk remains.

If the reported behavior was never supported and the outcome adds a new capability, require `Status: escalate`, set `Affected scope: feature-gap`, stop before Phase 2, and direct the user to `feature-workflow:feature-researching`.

For an accepted issue-backed diagnosis, post the terse diagnosis comment described below. Do not post comments for internal retries.

## Step 4: Spawn Phase 2 — Plan, Fix, Verify, and Commit

Use the attempt gate, then pass the accepted Diagnosis Checkpoint to a fresh Phase 2 agent. Require it to load and follow `superpowers:test-driven-development` and `superpowers:verification-before-completion`, remain on the established branch, and create a compact three-to-six-step in-session plan.

Require the agent to capture a failing regression test when practical; otherwise preserve the exact manual reproduction. It must implement the smallest sound root-cause fix, limit adjacent refactoring to correctness or testability, rerun the original reproduction, run regression and relevant neighboring verification, remove diagnostic residue and unrelated changes, and commit changed work on the active bugfix branch before returning.

Require this exact checkpoint:

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

A blocked agent may return without an artificial empty commit. A `fixed` result or changed `retryable` work is invalid without an attributable commit on the exact bugfix branch.

## Step 5: Validate the Resolution Checkpoint and Commit

Treat the returned result as untrusted until its exit status and complete final Resolution Checkpoint are valid. Then:

1. Confirm the returned commit exists on the expected bugfix branch.
2. Inspect the commit diff for scope, residue, and unrelated changes.
3. Rerun the original reproduction and proportionate verification.
4. Keep a successful commit.
5. Keep useful partial progress before a Phase 2 retry.
6. Reject a wrong attempt with `git revert`, never reset.
7. Revert and return to Phase 1 when the diagnosis is invalidated.

Never rewrite, reset, or silently discard attempt history. If a changed attempt is rejected, create an explicit revert commit before retrying or returning to diagnosis.

## Step 6: Route Completion, Retry, Re-Diagnosis, or Human Intervention

Route only as follows:

```text
Phase 1 ready -> Phase 2
Phase 1 retryable -> Phase 1, subject to the attempt gate
Phase 1 ambiguity/risk/escalate -> Human Intervention
Phase 2 fixed and independently verified -> Complete
Phase 2 retryable with valid diagnosis -> Phase 2, subject to the attempt gate
Phase 2 diagnosis-invalidated -> revert if needed, then Phase 1
Phase 2 ambiguity/risk/escalate -> Human Intervention
```

For an attempt cap, ambiguity, material risk, feature gap, or blocked result, stop and return this exact Human Intervention Checkpoint:

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

Keep public comments separate from internal checkpoints. Each comment is one or two sentences only:

- Diagnosis: reproduction + root cause + intended fix
- Resolution: implemented fix + passing verification
- Blocked: exhausted phase or material risk + decision needed

Do not comment on every retry. If a diagnosis is superseded, post one short correction. Do not mutate issue state beyond comments. If a comment fails, report it accurately without invalidating an otherwise verified fix.

## Completion Contract

Complete only when the original reproduction no longer fails, regression coverage or documented manual verification passes, relevant neighboring verification passes, the final diff is scoped and clean, the accepted fix commit exists on the bugfix branch, and no unresolved risk remains. When an issue is canonical, post the terse resolution comment or report its failure.

Finish with the root cause, fix, commit, verification, and residual risk. Keep push, PR creation, merge, and issue closure as separate explicit actions.

## Red Flags

- Investigating or spawning Phase 1 before the bugfix branch exists
- Treating an unsupported capability as a defect
- Starting Phase 2 without an evidence-backed root cause
- Spawning a fourth attempt, resetting counters, or repeating an unchanged failed approach
- Accepting changed Phase 2 work without its commit on the expected branch
- Using `git reset` or history rewriting to remove a failed attempt
- Claiming success without fresh independent verification
