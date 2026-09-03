---
name: feature-qa-review
description: Use after feature-implementing completes on a feature branch and before any finishing or publication work begins.
---

# Feature Workflow: QA Review Feature Branch

This is the mandatory independent gate between `feature-implementing` and `feature-finishing`. It is commit-bound, risk-adaptive, and incremental: review effort follows the changed surface, confirmed blockers stop progress, and reviewed fix deltas do not trigger unrelated full reruns.

## Mandatory First Action

Create this progress plan before other workflow actions:

```typescript
update_plan({
  "explanation": "Tracking risk-adaptive feature QA",
  "plan": [
    {"step": "Step 1: Bind the review target and source-of-truth contract", "status": "in_progress"},
    {"step": "Step 2: Build the verification ledger and compact QA brief", "status": "pending"},
    {"step": "Step 3: Classify risk and select the reviewer set", "status": "pending"},
    {"step": "Step 4: Run and inspect the selected independent reviews", "status": "pending"},
    {"step": "Step 5: Validate and disposition candidate findings", "status": "pending"},
    {"step": "Step 6: Resolve confirmed blockers in one approved fix wave", "status": "pending"},
    {"step": "Step 7: Review fix deltas and complete required verification", "status": "pending"},
    {"step": "Step 8: Persist Z06, obtain PASS acceptance, and hand off", "status": "pending"}
  ]
})
```

After each step, complete it and move `in_progress` to the next step.

## Gate Invariant

```text
UNRESOLVED CONFIRMED BLOCKER -> BLOCKED
FAILED OR MISSING REQUIRED VERIFICATION -> BLOCKED
FAILED, MISSING, OR UNINSPECTED SELECTED REVIEWER -> BLOCKED
UNREVIEWED IMPLEMENTATION DELTA -> BLOCKED
ADVISORY OR DISMISSED FINDING -> RECORDED, NOT BLOCKING
PASS WITHOUT EXPLICIT USER ACCEPTANCE -> FINISHING BLOCKED
ONLY AN ACCEPTED PASS MAY LAUNCH FEATURE-FINISHING
```

Severity informs prioritization but does not determine disposition by itself. A finding blocks only after evidence confirms its impact.

## Step 1: Bind the Review Target and Contract

Review the current feature branch against `main`. Run:

```bash
git branch --show-current
git rev-parse HEAD
git status --short
git diff main --name-only
git diff main
```

Stop on `main` or when tracked implementation changes are uncommitted. Preserve unrelated user changes without staging, discarding, or rewriting them.

Record HEAD as `Initial Reviewed Commit`. Discover the feature slug from Z02, then Z01, then the branch suffix. Reuse the feature's existing ongoing directory; otherwise try `docs/ai/ongoing/`, `.ai/ongoing/`, then `docs/ongoing/`.

Read `AGENTS.md`, `CLAUDE.md` when present, and only the source material needed to define expected behavior:

- `tracker-first`: the supplied or discoverable GitHub/Jira parent and child graph is authoritative.
- `local-artifacts-only`: Z01 and Z02 are authoritative; answered Z02 clarifications and Z99 are supporting evidence.
- `diff-only`: no tracker or workflow artifacts exist; record that limitation.

Documentation consistency remains owned by `feature-finishing`; QA reads documentation only when it defines implementation behavior.

## Step 2: Build the Verification Ledger and QA Brief

Read `{ONGOING_DIR}/Z98_{feature}_implementation_report.md` from the implementation handoff. If the handoff omits the path, try that exact expected filename; record missing Z98 as missing implementation evidence rather than reconstructing it from chat.

Consume Z98 and the handoff to record:

- each verification command, outcome, and available evidence
- checks skipped, unavailable, or incomplete
- focused checks and final feature verification
- the final runtime-affecting commit and later documentation-only or unrelated commits
- verification reuse and invalidation decisions
- repository-required QA-specific commands

Evidence is reusable only when it is complete, successful, inspectable, and bound to code that remains unchanged at the reviewed commit. Chat claims without command/outcome evidence are not reusable.

Evidence from an ancestor commit may remain valid when:

- the evidence commit is reachable from `Initial Reviewed Commit`
- Z98 records its coverage and no invalidating commit
- independent diff inspection confirms intervening commits are documentation-only or do not intersect the covered runtime surface
- the relevant environment remains equivalent

Do not reject valid evidence merely because final HEAD contains later documentation-only commits. Reject or rerun evidence when ancestry, coverage, environment, output, or invalidation cannot be established.

Build a compact reviewer brief containing:

- branch, `main` comparison, and full commit SHA
- changed files and relevant diff
- source-of-truth mode and acceptance contract
- applicable repository constraints
- Z98 implementation-report path and final runtime-affecting commit
- reusable verification ledger
- finding schema

Do not pass complete Z01/Z02/tracker dumps when a focused contract excerpt is sufficient.

Candidate finding schema:

```text
title
type
severity
file
lines
evidence
impact
suggested_action
reported_by
```

Types: `Security`, `Bug`, `Contract Deviation`, `Tests`, `Code Quality`. Severities: `Critical`, `High`, `Medium`, `Low`.

## Step 3: Classify Risk and Select Reviewers

Select the smallest reviewer set that covers the observed risk:

- `Standard`: one integrated reviewer.
- `Elevated`: integrated reviewer plus one relevant specialist.
- `Critical`: integrated reviewer plus at most two relevant specialists.

The integrated reviewer is always mandatory and covers functional correctness, contract conformance, test adequacy, maintainability, and likely review friction.

Add a security specialist when the diff changes a trust boundary, including authentication, authorization, permissions, secrets, sensitive data, external input, dependency security, or comparable exposure.

Add one domain specialist when the diff contains a distinct high-impact surface the integrated reviewer cannot adequately cover, such as destructive data/schema work, concurrency, public compatibility, or another repository-specific critical invariant. Do not add specialists merely because a profile exists.

Record the risk level, concrete risk signals, selected reviewers, and why omitted specialists were unnecessary.

## Step 4: Run the Selected Independent Reviews

Dispatch selected reviewers with the active runtime's native collaboration tools. Never launch a nested Codex CLI process for review delegation. Reviewers must be isolated from implementation-session conclusions and receive only the compact brief plus their mission.

Use the native collaboration schema actually exposed by the runtime; keep tool signatures and model names out of this workflow so they cannot become stale.

On Codex:

- spawn each reviewer with `fork_turns: "none"`
- set both `model` and `reasoning_effort` explicitly from the current spawn allowlist, sized to the review risk
- dispatch independent selected reviewers concurrently
- while idle, use event waits of 5–10 minutes rather than short polling or repeated unchanged status narration
- inspect every final reviewer response; for an incomplete or malformed response, request one correction from that reviewer
- after a failed or timed-out reviewer, or when that correction remains unusable, reconcile native agent status once; if no usable result exists, dispatch one fresh replacement with the same brief, then block and report the process failure if the replacement also fails

Reviewers inspect Z98 verification entries and captured output; they do not rerun implementation commands. The QA controller alone decides whether evidence is missing, stale, suspicious, failed, or invalidated and therefore requires execution under Step 7.

Require `No findings` or candidate findings in the schema. Inspect every selected result. Missing, timed-out, malformed, or uninspected output is a process blocker for that selected reviewer.

Normalize and de-duplicate candidate findings while preserving provenance. Reviewer output is evidence to validate, not an automatic verdict.

## Step 5: Validate and Disposition Findings

Validate each candidate against the code, authoritative contract, and reproducible evidence. Assign exactly one disposition:

- `Blocking Confirmed`: a demonstrated functional, security, or data-integrity defect; authoritative acceptance/contract violation; or missing/failed verification required to establish correctness.
- `Advisory`: a worthwhile improvement that does not prevent the feature from satisfying its contract safely, including optional coverage or maintainability work.
- `Dismissed`: contradicted by the code/contract, not reproducible, duplicate, or outside the feature scope.

Record evidence and rationale for every disposition. Documentation drift owned by finishing is advisory unless it exposes an immediate operational or security failure.

If there are no confirmed blockers, continue to Step 7. Otherwise present the complete blocker set and advisory summary once, then ask:

```text
1) Fix all confirmed blockers and record advisories
2) Review decisions individually
3) Stop and leave QA blocked
```

Do not mutate code or trackers before the user chooses.

## Step 6: Resolve Confirmed Blockers

For an approved fix wave:

1. Load the relevant debugging/fixing skill once for the wave.
2. Apply the smallest safe fixes for all approved blockers.
3. Run affected verification.
4. Commit the fix wave on the feature branch.
5. Record the new HEAD as the candidate commit.

Advisories may be recorded in Z06 or in a tracker follow-up when the target and authorization are unambiguous. They do not block PASS.

## Step 7: Review Fix Deltas and Complete Verification

When implementation changed after the initial review, run one isolated fix-delta review over `Initial Reviewed Commit..candidate commit`. It must:

- verify every original blocker is addressed
- review the fix delta for new defects
- inspect interactions with the affected surrounding code

Re-run a selected specialist only when the delta touches that specialist's risk surface or the original blocker belonged to that domain.

If a fix introduces new behavior or materially broadens the changed surface, reclassify risk and run the newly selected reviewer set against the candidate. Otherwise the inspected fix-delta review covers the new implementation delta. Repeat only for subsequent changed ranges; never rerun unrelated reviewers by default.

Verification policy:

- always run `git diff --check` against the final candidate
- reuse valid implementation evidence that remains bound to unchanged code
- run targeted checks required by findings, fix deltas, or uncovered risks
- rerun checks invalidated by implementation changes
- run the full suite only when evidence is missing/stale, repository instructions explicitly require a fresh QA run, risk selection requires it, or the fix invalidates the prior full-suite result

Set `Reviewed Commit` to the full final candidate HEAD after review and verification complete. When no fixes were needed, it equals `Initial Reviewed Commit`.

The candidate is eligible for acceptance only when all selected reviews succeeded, all implementation deltas were reviewed, unresolved confirmed blockers equal zero, required verification passed or remains valid, HEAD equals `Reviewed Commit`, and no uncommitted implementation changes remain.

## Step 8: Persist Z06, Accept PASS, and Hand Off

Always create `{ONGOING_DIR}/Z06_{feature}_qa_review.md` with this header:

```markdown
# Feature QA Review: {Feature Name}

**Date**: {date}
**Branch**: {branch}
**Initial Reviewed Commit**: {full SHA}
**Reviewed Commit**: {final candidate full SHA}
**Runtime Verification Commit**: {full SHA or None}
**Implementation Report**: {Z98 path or Missing}
**Fix Review Ranges**: {ranges or None}
**Source of Truth**: {tracker-first | local-artifacts-only | diff-only}
**Risk Level**: {Standard | Elevated | Critical}
**Selected Reviewers**: {reviewers}
**Unresolved Blocking Findings**: {count}
**Verdict**: BLOCKED
**User Acceptance**: Not accepted
**Files Changed**: {count}
**Verification Reused**: {commands/outcomes or None}
**Verification Run During QA**: {commands/outcomes}
```

Include risk rationale, reviewer outcomes, every candidate finding and disposition, fix commits/ranges, and verification invalidation decisions.

If any gate condition fails, leave `Verdict: BLOCKED`, report the exact blocker, and do not launch finishing.

When the candidate is eligible, present its commit, risk/reviewer summary, finding dispositions, and verification evidence, then ask:

```text
Accept QA PASS for {reviewed commit} and continue to feature-finishing?
1) Accept and continue
2) Do not accept
```

Only after explicit acceptance update Z06 to `Verdict: PASS` and `User Acceptance: Accepted`, then invoke `feature-workflow:feature-finishing` with the Z06 path, branch, final reviewed commit, feature slug, and ongoing directory.

## Red Flags

- Used chat memory instead of commit/source evidence
- Ignored an available Z98 implementation report
- Rejected valid ancestor evidence only because documentation-only commits followed it
- Asked a reviewer to rerun implementation verification instead of inspecting its evidence
- Selected no integrated reviewer
- Added specialists without an observed risk signal
- Trusted an uninspected selected-reviewer result
- Treated a candidate finding as automatically blocking
- Dismissed a finding without evidence
- Passed with unresolved confirmed blockers or failed required verification
- Reused verification after its code was invalidated
- Left an implementation delta unreviewed
- Reran every reviewer after a scoped fix without reclassified risk
- Issued PASS before explicit acceptance or skipped Z06

## Common Rationalizations

| Excuse | Reality |
|---|---|
| "Five reviewers are always safer." | Reviewer count follows independent risk signals; redundant profiles add cost without proportional coverage. |
| "Every finding must block." | Only validated correctness, security, contract, data-integrity, or required-verification failures block. |
| "A fix invalidates the entire QA history." | The initial review covers its commit; an inspected fix-delta review covers scoped subsequent changes. |
| "Implementation verification must always be rerun." | Commit-bound evidence remains valid until affected code changes or a repository/risk requirement demands a fresh run. |
| "The user wants speed, so acceptance is implied." | Finishing still requires explicit acceptance of the final reviewed commit. |

## Success Criteria

- Bound QA to initial and final full commit SHAs
- Loaded the authoritative contract, Z98 report, and compact verification ledger
- Independently validated reused evidence against commit ancestry, covered code, and environment
- Selected and inspected the smallest risk-appropriate independent reviewer set
- Validated and dispositioned findings with evidence
- Batched approved blocker fixes and reviewed every implementation delta
- Reused only valid commit-bound verification and ran affected checks
- Recorded zero unresolved blockers before PASS eligibility
- Created Z06 with risk, reviewers, dispositions, verification, and reviewed ranges
- Invoked `feature-finishing` only after explicit acceptance of the final reviewed commit
