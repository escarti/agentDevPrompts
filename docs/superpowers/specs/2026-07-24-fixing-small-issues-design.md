# Fixing Small Issues Design

## Summary

Add one public `fixing-small-issues` skill for short, bounded bugfixes, hotfixes, regressions, failing tests, and small corrective improvements. It preserves a research, planning, implementation, and verification discipline without using the feature workflow's Z01/Z02/Z99/Z06 artifacts, phased PR plans, batch approvals, or multi-profile QA gate.

The coordinator stays context-light by delegating diagnosis and implementation to fresh sequential sub-agents. It retains only structured checkpoints, attempt counters, risk decisions, and concise user-facing status.

## Goals

- Accept a GitHub issue or a direct description of incorrect behavior.
- Create a dedicated bugfix branch before investigation begins.
- Separate diagnosis from implementation.
- Keep heavyweight repository exploration inside sub-agents.
- Continue autonomously while evidence supports a bounded, low-risk fix.
- Run either phase at most three times, then request human intervention before a fourth execution.
- Require every implementation attempt that changes the workspace to return committed work.
- Verify the original reproduction and relevant regression coverage before success.
- Use concise GitHub issue comments as durable public checkpoints.

## Non-Goals

- Implement new features or fill product capability gaps.
- Replace the feature workflow for broad, architectural, security-sensitive, migration-heavy, or product-ambiguous work.
- Create local Z artifacts or tracker task graphs.
- Run multiple review profiles for ordinary small fixes.
- Push, open a pull request, merge, close an issue, change labels, or assign users without an explicit request.
- Hide uncertainty behind repeated speculative implementation attempts.

## Public Surface

- Skill: `feature-workflow:fixing-small-issues`
- Thin command wrapper: `/fix-small-issue`

The skill is the single workflow owner. Phase 1 and Phase 2 are internal sub-agent roles, not additional public skills or commands.

## Source Resolution

Input priority:

1. An explicitly supplied GitHub issue.
2. A GitHub issue unambiguously identified by the current task context.
3. A direct bug description, failing test, error, log, or observed misbehavior.

When an issue exists, it is the canonical problem statement. Without an issue, the Codex task is sufficient; the coordinator must not force tracker creation.

## Mandatory Branch Setup

A dedicated branch is a precondition for Phase 1. The only actions allowed before branch creation are:

- read repository instructions;
- resolve enough source context to derive a branch slug;
- inspect git branch, worktree, and base-branch safety.

Branch names:

- GitHub issue: `bugfix/<issue-number>_<bug-slug>`
- Direct report: `bugfix/<bug-slug>`

New bugfix branches start from `main` unless the user explicitly authorizes another base. If already on the exact expected bugfix branch, resume it. Detached HEAD, an unrelated branch, unclear provenance, or unrelated dirty changes are risk gates and must pause before any sub-agent starts. Existing user changes must never be silently discarded.

## Coordinator Responsibilities

The coordinator owns:

- source resolution and repository-instruction loading;
- branch creation, validation, and resume identity;
- independent Phase 1 and Phase 2 attempt counters;
- narrow sub-agent briefs and lifecycle control;
- structured checkpoint validation;
- transition, retry, revert, escalation, and completion decisions;
- concise GitHub comments;
- independent verification of the returned commit and final diff;
- user communication.

The coordinator does not perform deep code exploration or implementation itself. It must not act as a blind relay: a sub-agent result is untrusted until its checkpoint, branch, commit, and verification evidence satisfy the relevant contract.

## Context-Isolation Model

Each attempt uses a fresh sequential sub-agent. Phase agents never run in parallel.

The coordinator passes only:

- the canonical issue or direct problem statement;
- the active bugfix branch identity;
- relevant repository constraints;
- the current phase and attempt number;
- the latest accepted checkpoint;
- exact failure evidence needed for a retry.

The coordinator does not pass full prior transcripts or exploration logs. Sub-agent logs are retained for launch/result validation, and every log is checked for exit status and a complete final checkpoint. Normal coordinator context receives only that compact checkpoint; the complete log is loaded only when a result is missing, malformed, contradictory, or otherwise untrustworthy.

Sub-agents must stop and return control at the end of their assigned phase. They may not continue into another phase or spawn the next attempt.

## Phase 1: Reproduce and Diagnose

Phase 1 is investigative and must not modify production code.

The Phase 1 agent:

1. Establishes expected and actual behavior.
2. Defines the smallest practical reproduction.
3. Inspects relevant code, tests, history, and nearby repository patterns.
4. Reproduces the failure or establishes equivalent deterministic evidence when direct reproduction is impractical.
5. Forms and tests competing hypotheses.
6. Identifies the causal chain rather than only the failing line.
7. Compares credible fix options and recommends one.
8. Defines Phase 2 success and verification criteria.

Temporary diagnostic instrumentation is allowed but must be removed before return. Phase 1 must leave no tracked changes.

### Diagnosis Checkpoint

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

The coordinator accepts `ready` only when the root cause is evidence-backed, the recommendation is bounded, and the success criteria are testable.

If investigation shows that the reported behavior is not a regression or defect but a missing capability, classify it as a feature gap, return `Status: escalate`, and do not enter Phase 2.

## Phase 1 Transition Gate

After an accepted Diagnosis Checkpoint:

- Continue automatically to Phase 2 when the recommended fix is bounded and low-risk.
- Retry Phase 1 when new investigation has a credible path and no human decision is required.
- Pause for ambiguity when expected behavior or materially different fixes require a user choice.
- Pause for risk when the work involves contracts, migrations, security, data loss, broad refactoring, or feature-like scope.
- Stop and direct the user to `feature-workflow:feature-researching` when the request is a new feature, the diagnosis reveals a feature gap, or the scope is no longer a small bugfix.

## Phase 2: Plan, Fix, and Verify

Every Phase 2 attempt receives the accepted Diagnosis Checkpoint and creates a compact in-session plan, normally three to six concrete steps. It does not create Z02 or Z99.

The Phase 2 agent:

1. Confirms the branch identity and current working-tree state.
2. Captures the bug with a failing regression test when practical; otherwise preserves the exact manual reproduction.
3. Implements the smallest sound fix.
4. Limits adjacent refactoring to what is necessary for correctness or testability.
5. Reruns the original reproduction.
6. Runs the regression test, relevant neighboring tests, and proportionate lint, type-check, build, or broader verification.
7. Removes diagnostic residue and unrelated changes.
8. Commits the attempt on the active bugfix branch before returning control.

If the agent cannot safely modify or commit because it discovers ambiguity or risk, it returns `blocked` without manufacturing an empty commit or claiming completed work.

### Resolution Checkpoint

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

A `fixed` result is invalid without an attributable commit on the expected bugfix branch and fresh passing verification.

## Coordinator Validation and Commit Disposition

After every Phase 2 return, the coordinator:

1. Confirms the commit exists on the expected bugfix branch.
2. Inspects the diff and verifies it contains no diagnostic residue or unrelated changes.
3. Reruns the original reproduction and proportionate verification.
4. Chooses one disposition:
   - Keep the commit and complete.
   - Keep useful partial progress and launch another Phase 2 attempt.
   - Revert the attempt with a new commit, then retry Phase 2.
   - Revert the attempt and return to Phase 1 because the diagnosis was invalidated.

The workflow must not rewrite, reset, or silently discard attempt history. Any rejected attempt commit is removed with an explicit revert commit.

## Attempt Counters and Retry Semantics

The coordinator initializes:

```text
phase_1_attempts = 0
phase_2_attempts = 0
```

Before spawning either phase:

```text
if phase_attempts >= 3:
    block and request human intervention
else:
    phase_attempts += 1
    spawn the phase agent
```

Rules:

- Each phase may execute at most three times per coordinator run.
- The counters are independent and cumulative.
- Moving between phases does not reset either counter.
- A successful third attempt completes normally.
- Blocking occurs only when the coordinator would otherwise spawn a fourth attempt.
- Resuming the same coordinator task preserves its counters; an explicitly new coordinator run starts at zero.

A retry must be evidence-driven. The coordinator must provide new failure evidence or require a meaningfully different investigation or correction. Repeating an unchanged unsuccessful approach is not a valid retry.

### Loop Routing

```text
Phase 1
  ├─ accepted diagnosis ────────────────> Phase 2
  ├─ retryable ─────────────────────────> Phase 1
  └─ ambiguity/risk/cap ────────────────> Human

Phase 2
  ├─ fixed and independently verified ──> Complete
  ├─ diagnosis still valid, incomplete ─> Phase 2
  ├─ diagnosis invalidated ─────────────> Phase 1
  └─ ambiguity/risk/cap ────────────────> Human
```

## Human Intervention Checkpoint

When ambiguity, risk, or an attempt cap blocks progress, return:

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

The workspace and branch remain recoverable and unchanged except for explicit attempt and revert commits already made.

## GitHub Issue Comments

When a GitHub issue is canonical, the coordinator automatically adds thin checkpoint comments:

- Accepted diagnosis: one or two sentences covering reproduction, root cause, and intended fix.
- Successful resolution: one or two sentences covering the fix and passing verification.
- Human intervention: one or two sentences stating the exhausted phase or risk and the decision needed.

Do not post comments for every internal retry. If a later diagnosis supersedes an earlier accepted diagnosis, post one short correction. Detailed checkpoints, logs, attempt histories, and test output remain in the Codex task.

The coordinator does not rewrite the issue body, change labels, assign users, close the issue, or change issue state without an explicit request. A failed comment operation is reported accurately but does not invalidate a verified code fix.

## Completion Contract

The bugfix is complete only when:

- the original reproduction no longer fails;
- regression coverage passes or the documented manual verification succeeds;
- relevant neighboring verification passes;
- the final diff is scoped and clean;
- the accepted fix commit exists on the bugfix branch;
- no unresolved risk remains;
- the concise resolution comment was posted when an issue is canonical, or a comment failure was explicitly reported.

The coordinator finishes with a concise summary of the root cause, fix, commit, verification, and any residual risk. Push, PR creation, merge, and issue closure remain separate explicit actions.

## Repository Integration

Implementation is expected to add or update:

- `skills/fixing-small-issues/SKILL.md`
- `commands/fix-small-issue.md`
- `skills/obsolete compatibility helper/SKILL.md`
- `AGENTS.md`
- `CLAUDE.md`
- `README.md`
- plugin metadata where the public skill surface or description is enumerated
- `CHANGELOG.md` when preparing the eventual release

The coordinator should reuse the repository's sub-agent launch, timeout, log-validation, systematic-debugging, test-driven-development, and verification-before-completion conventions while keeping the public workflow to one skill and one command.

## Acceptance Scenarios

1. A GitHub issue creates the expected bugfix branch before Phase 1, produces a diagnosis comment, commits a verified fix, and produces a terse resolution comment.
2. A direct misbehavior description follows the same phases without requiring an issue or local artifact.
3. Phase 1 succeeds on attempt three and proceeds to Phase 2 without blocking.
4. A fourth attempted Phase 1 spawn is blocked with a Human Intervention Checkpoint.
5. Phase 2 preserves a useful failed-attempt commit and fixes on a later committed attempt.
6. Phase 2 reverts a wrong attempt commit before retrying.
7. Phase 2 invalidates the diagnosis and routes back to Phase 1 without resetting either counter.
8. Phase 2 succeeds on attempt three and completes without blocking.
9. A fourth attempted Phase 2 spawn is blocked with a Human Intervention Checkpoint.
10. Dirty, detached, or ambiguous branch state pauses before any phase agent starts.
11. Feature-like scope or material security, migration, contract, or data risk pauses for human intervention.
12. GitHub comments remain one or two sentences and exclude detailed logs or checkpoint payloads.
13. A bug report that Phase 1 identifies as a feature gap stops before Phase 2 and routes to `feature-workflow:feature-researching`.
