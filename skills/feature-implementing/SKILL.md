---
name: feature-implementing
description: Use when implementing an approved local Z02 plan or published GitHub/Jira feature graph.
---

# Feature Workflow: Implement Feature

## Purpose

Execute an approved feature in phase-scoped batches while preserving branch provenance, one attributable commit per task or tracker child, focused verification, durable evidence, and approval before entering each new phase.

Core invariants:

- local-plan mode uses Z99 as live progress; tracker mode uses GitHub or Jira and never Z99
- both modes write implementation evidence to `Z98_{feature}_implementation_report.md`
- batches stay inside one phase and normally contain two dependency-ready items
- batching never combines task or child commits, results, or focused verification
- execution continues automatically inside a phase; approval belongs at the next phase boundary
- integrated targeted and required regression verification run once at the final runtime-affecting HEAD
- implementation hands off to `feature-qa-review`, never directly to finishing

## Mandatory Progress Plan

Create this plan before workflow actions:

```typescript
update_plan({
  "explanation": "Tracking feature implementation workflow",
  "plan": [
    {"step": "Step 1: Resolve the source, feature identity, and authoritative context", "status": "in_progress"},
    {"step": "Step 2: Build or resume local-plan or tracker execution state", "status": "pending"},
    {"step": "Step 3: Establish or validate the feature branch", "status": "pending"},
    {"step": "Step 4: Select the execution mode", "status": "pending"},
    {"step": "Step 5: Run shared preflight and select the next phase batch", "status": "pending"},
    {"step": "Step 6: Execute and validate the batch", "status": "pending"},
    {"step": "Step 7: Continue within the phase or request phase-boundary approval", "status": "pending"},
    {"step": "Step 8: Run final commit-bound verification", "status": "pending"},
    {"step": "Step 9: Enforce the completion gate", "status": "pending"},
    {"step": "Step 10: Hand off to feature-qa-review", "status": "pending"}
  ]
})
```

Complete each step before advancing the plan.

## Step 1: Resolve Source and Context

Supported sources:

- local: `Z02_{feature}_plan.md`
- GitHub: parent roadmap issue plus children published by `feature-planning`
- Jira: epic plus children published by `feature-planning`

If the user names a source, use it. Otherwise prefer a discovered local Z02. Ask only when multiple valid candidates remain. If no supported source exists, stop and route to `feature-planning`.

Resolve:

- feature slug from Z02 or published planning metadata; otherwise normalize the parent title
- `ONGOING_DIR` from the local plan or existing feature artifacts; otherwise `docs/ai/ongoing/`
- tracker entrypoint when applicable

Stop if a stable feature identity or tracker entrypoint cannot be resolved safely.

Before implementation, read:

1. `AGENTS.md`, then `CLAUDE.md` when present
2. `Z01_{feature}_research.md` when present
3. the authoritative planning source
4. answered `Z02_CLARIFY_{feature}_plan.md` when present

If any `User response:` in Z02_CLARIFY is blank, stop until it is answered.

Tracker execution is valid only when the parent and children preserve:

- self-contained implementation context
- ordered phases or an equivalent ordered sequence
- explicit dependency edges
- Z02 task-to-slice traceability
- focused verification in every child
- parent-owned final feature verification

Reject a graph that cannot be executed without consulting transient local planning files.

## Step 2: Build or Resume Execution State

### Local-plan mode

Use `{ONGOING_DIR}/Z99_implementation_status.md` as the live checklist.

- normalize Z02 into ordered phases, tasks, dependencies, and checkpoints
- preserve existing status and proof when resuming
- statuses are `pending`, `in_progress`, `done`, or `blocked`
- persist `Feature branch:` as the authoritative resume identity
- keep `Current batch` and `Blockers` sections
- require one isolated, attributable commit per completed Z02 task
- never edit Z02 to track execution

### Tracker mode

The tracker is the live checklist.

- never create, read, or depend on Z99
- open children are remaining work
- phase order and explicit predecessors control execution order
- one parent issue or epic uses one branch
- require one isolated, attributable commit per completed child
- close a child only after its commit is validated on the feature branch and focused verification is recorded

### Shared implementation report

Create or resume `{ONGOING_DIR}/Z98_{feature}_implementation_report.md`. Z98 records evidence and decisions; it does not replace Z99 or tracker state.

Record:

- source mode, branch, base commit, and tracker entrypoint
- shared preflight
- task or child results and commits
- verification execution, reuse, and invalidation
- phase summaries, approvals, blockers, and rulings

Verification entries use:

```yaml
commit: <full SHA>
runtime_affecting: true | false
suite: <focused, phase, targeted-integrated, regression, or repository-specific>
command: <exact command>
environment: <worktree and relevant runtime identity>
result: PASS | FAIL | INCONCLUSIVE
covers: <files, component, behavior, or invariant>
evidence: <exit status plus relevant output or precise report reference>
invalidated_by: <full SHA or None>
```

Keep evidence concise and inspectable; do not dump unrelated logs.

## Step 3: Establish or Validate the Feature Branch

New feature work branches from `main` unless the user explicitly authorizes another base.

Expected branch:

- local: `feature/<feature-slug>`
- tracker: `feature/<parent-id>_<feature-slug>`

Inspect the current branch, HEAD state, worktree, and base provenance.

- detached HEAD: stop
- on `main`: create or switch to the expected feature branch and record the base
- on another branch: resume only when it exactly matches Z99 `Feature branch:` or the inferable tracker branch
- mismatch or unclear provenance: stop and ask

Executors must remain on this branch. Branch or worktree drift stops the batch immediately.

## Step 4: Select Execution Mode

Always ask once:

1. Subagent-Driven (recommended) — use `superpowers:subagent-driven-development` for each selected batch.
2. Inline Execution — use `superpowers:executing-plans` for each selected batch.

Load only the selected installed plugin skill directly; do not load both executors speculatively. If it is unavailable, stop and report its exact name, explaining that the Superpowers plugin must be enabled before starting a fresh session. Do not invent another execution mode.

## Step 5: Run Shared Preflight and Select a Phase Batch

Before the first implementation dispatch, run one preflight for the established branch and worktree:

- confirm branch and worktree identity
- confirm required project dependencies
- when implementation or verification uses Docker or Compose, check the daemon and Compose configuration once
- start or mutate local services only when already authorized by the implementation workflow
- record commands, outcomes, and environment identity in Z98

Pass the result to every executor. Do not repeat preflight per child. Repeat only when the worktree or relevant environment changes, evidence is incomplete, or later evidence shows it is stale.

Select 1-3 dependency-ready tasks or slices from the earliest unfinished phase. Normally select 2.

Use 1 when an item is high-risk, unusually large, needed before another can start, or cannot otherwise retain isolated proof. Use up to 3 only when every item:

- belongs to the same phase
- has satisfied dependencies
- can be executed without conflicting work
- retains its own commit, focused verification, and structured outcome

Never cross a phase boundary to enlarge a batch. Batch size is a ceiling, not a quota.

- local mode: select unfinished Z99 tasks and persist `Current batch`
- tracker mode: select open children from tracker state; never mirror the batch into Z99

## Step 6: Execute and Validate the Batch

`feature-implementing` owns sequencing, live state, evidence validation, and phase approval. The executor owns only the current batch.

### Superpowers batch adapter

For Subagent-Driven execution, materialize the selected batch as `{ONGOING_DIR}/Z98_{feature}_batch_{phase}_{batch}_plan.md` before invoking Superpowers. Make it a valid `subagent-driven-development` plan containing:

- the authoritative source or spec reference
- a `Global Constraints` section
- one `### Task N:` section per selected Z02 task or tracker child
- the original task or child identifier, acceptance criteria, focused verification, and commit-isolation requirement in each task

Use that batch plan as `PLAN_FILE` for `subagent-driven-development`. Reuse the feature branch and established worktree; its worktree setup verifies the existing workspace instead of creating another. Record the batch base commit before execution.

Keep Superpowers' native implementer, per-task reviewer, fix-loop, and final batch-review behavior. Do not coalesce distinct Z02 tasks or tracker children into one Superpowers task because their commits and outcomes must remain isolated.

The adapter changes only the terminal handoff:

- scope the final review to `batch base..batch HEAD`
- do not invoke `finishing-a-development-branch`, push, publish, or enter later feature work
- return the SDD ledger, task reports, review results, rulings, commits, and verification evidence to `feature-implementing`
- preserve the SDD workspace and batch plan until the controller has inspected those artifacts, copied accepted evidence into Z98, and updated live state
- after a successful batch ingestion, remove only that completed batch's SDD workspace and temporary plan; retain both for blocked or incomplete batches so they can resume

Give the executor a compact file-based brief containing:

- active phase and exact batch items
- feature branch and approved base
- dependencies, relevant constraints, acceptance criteria, and focused verification
- Z98 path, shared preflight, and reusable verification entries
- tracker-specific commit and result isolation rules
- the requirement to stop on branch drift
- the requirement to return after this batch completes or stops early

Do not pass full artifact dumps or later-phase work.

For Inline Execution, execute only the batch and do not claim reviewer-subagent coverage.

Every returned item must include:

- identifier and `done`, `blocked`, or `incomplete`
- an already-existing attributable commit for `done`
- proof the commit is on the established feature branch
- focused verification command, result, coverage, and evidence
- blocker details when applicable

For a multi-item batch, no two items may share a completion commit.

After return:

1. inspect the SDD ledger and reports when Subagent-Driven mode was used
2. validate every commit on the feature branch
3. validate focused verification and review evidence
4. append accepted results, rulings, and evidence to Z98
5. update Z99 or close/update tracker children immediately
6. mark missing or invalid proof as `incomplete`

Changes invalidate only evidence covering the changed surface. Documentation-only commits do not invalidate runtime evidence. After a runtime change, run only checks covering the changed area; do not rerun unrelated successful checks.

Apart from a planned phase boundary, stop early only for:

- a blocker with no safe path forward
- branch or worktree drift
- a destructive, security-sensitive, or external side effect requiring new authority
- material plan ambiguity whose viable interpretations produce meaningfully different behavior

Resolve ordinary uncertainty from the authoritative contract, record the ruling in Z98, and continue.

## Step 7: Continue or Request Phase Approval

If dependency-ready work remains in the same phase, select the next batch and continue without asking for approval. Normal batch completion is not a decision point.

At a phase boundary:

- validate every result and commit in the phase
- run only a distinct declared phase check not already covered by focused evidence
- defer broader integrated and regression commands to Step 8
- record the summary, verification reuse or execution, rulings, and blockers in Z98
- ask for approval before entering the next phase

After the final phase, continue directly to Step 8. If the user pauses at a boundary, Z99 or tracker state plus Z98 are the resume state.

## Step 8: Run Final Commit-Bound Verification

Evidence is keyed by exact commit, command, and relevant environment. Never rerun successful, inspectable verification against the same commit and equivalent environment.

A same-commit rerun is allowed only when evidence is missing, incomplete, inconclusive, suspicious, the environment changed, or repository/user instructions explicitly require it.

At the final runtime-affecting HEAD:

- run the integrated targeted suite once
- run the repository-declared regression command once, including `make regression` when that is the declared command
- omit a narrower command fully subsumed by a broader command unless it covers distinct behavior or configuration
- record commands, coverage, results, and evidence in Z98

Documentation-only commits after that runtime HEAD retain this evidence.

If final verification fails:

- keep completion blocked
- commit the smallest correction with clear task, child, or parent attribution
- rerun the failed checks and only checks invalidated by the correction
- record invalidation and replacement evidence in Z98

Tracker parent-owned cross-cutting verification or correction work remains on the feature branch with clear parent attribution. Do not reopen unrelated children unless their focused evidence was invalidated.

## Step 9: Enforce Completion

Local-plan mode is complete only when:

- every Z02 task exists in Z99 and is `done`
- every task has proof and a validated, unique commit
- Z99 records the active feature branch
- Z98 contains task evidence, phase evidence or coverage decisions, final targeted evidence, and required regression evidence or an explicit not-applicable decision
- required verification passed or remains valid at the final runtime-affecting HEAD

Tracker mode is complete only when:

- every child is done in the tracker
- every child has a validated, unique commit and focused evidence
- dependency order and branch identity remain valid
- Z98 contains child evidence, phase evidence or coverage decisions, final targeted evidence, and required regression evidence or an explicit not-applicable decision
- parent final verification passed once at the final runtime-affecting HEAD

If the active mode fails its gate, keep implementation in progress and do not claim completion.

## Step 10: Hand Off to Feature QA Review

After Step 9 passes, invoke `feature-workflow:feature-qa-review`. Never invoke or hand off directly to `feature-finishing`.

Pass:

- branch, source mode, feature slug, and `ONGOING_DIR`
- final HEAD and final runtime-affecting commit
- tracker entrypoint when applicable
- Z98 path and shared preflight result
- focused, phase, targeted-integrated, and regression evidence
- verification reuse and invalidation decisions
- skipped, unavailable, or incomplete checks

Implementation evidence is commit-bound input to independent QA, not a substitute for it. If QA is unavailable or returns `BLOCKED`, return control. Only QA may invoke finishing after recording a `PASS` with zero unresolved blockers and receiving explicit user acceptance.

## Red Flags

- using tracker mode with Z99
- continuing on an unrelated or unclear branch
- crossing phases to fill a batch
- combining task or child commits, verification, or results
- repeating preflight per child without changed environment evidence
- asking for routine approval between batches in the same phase
- rerunning successful same-commit evidence without an allowed reason
- rerunning unrelated checks after a scoped change
- closing work without validated commits and focused evidence
- omitting Z98 or its QA handoff
- invoking finishing directly

## Success Criteria

- authoritative source, feature identity, branch, and live state were validated
- one shared preflight was reused while the environment remained stable
- phase batches contained 1-3 dependency-ready items, normally 2
- every item retained an isolated commit, result, and focused verification
- execution continued automatically inside phases and paused before entering the next phase
- Z98 captured proof, verification reuse, invalidation, and phase decisions
- final targeted and required regression verification ran once at the final runtime-affecting HEAD
- QA received the complete commit-bound handoff

## Integration

```text
feature-researching -> feature-planning -> feature-implementing
                    -> feature-qa-review -> feature-finishing
```

Use this skill only for an approved Z02 plan or published tracker graph. Route simple one-step defects to the repository's small-fix workflow.
