---
name: feature-pr-reviewing
description: Review an independently submitted pull request using a commit-bound, risk-adaptive set of reviewers, then disposition each finding for commenting, fixing, or ignoring. Do not use to certify undocumented product intent.
---

# Review Pull Request

Review the supplied PR as a standalone task. Bind the review to exact commits, select only the reviewers justified by the changed surface, validate their candidate findings, and let the user decide how to handle each reportable issue. The PR description and linked requirements may supply a contract, but never infer or certify undocumented product intent.

## Review Invariants

```text
UNRESOLVED PR TARGET OR HEAD COMMIT -> REVIEW BLOCKED
FAILED, MISSING, OR UNINSPECTED SELECTED REVIEWER -> REVIEW INCOMPLETE
UNREVIEWED PR DELTA -> REVIEW OUTDATED
CANDIDATE FINDING WITHOUT VALIDATION -> DO NOT REPORT AS CONFIRMED
NO DOCUMENTED REQUIREMENT -> NO CLAIM OF REQUIREMENT CONFORMANCE
NO EXPLICIT WRITE REQUEST -> DO NOT POST COMMENTS OR CHANGE CODE
A FINDING DECISION -> AUTHORIZATION ONLY FOR THE ACTION IT NAMES
```

Severity prioritizes confirmed findings; it does not turn speculation into a defect.

## 1. Bind the Review Target

Read `AGENTS.md` first, then `CLAUDE.md` when present, followed by only the repository context needed to understand the changed areas.

Resolve the PR explicitly supplied by the user. If no PR number, URL, branch comparison, or diff was supplied, ask for one instead of discovering an arbitrary PR.

For a GitHub PR, collect at least:

- PR URL, title, author, and description
- base and head branch names
- full base and head commit SHAs
- changed files and complete diff
- available status-check and test evidence

Use `gh pr view` and `gh pr diff` without checking out the PR when they provide enough evidence. Check out code only when local inspection or verification genuinely requires it, and preserve unrelated user changes.

Record the full head SHA as `Initial Reviewed Commit`. The review covers that commit, not the moving PR branch name.

## 2. Establish the Available Contract and Review Brief

Build the behavioral contract only from evidence available to an external reviewer:

- the PR title and description
- supplied or directly linked issue and acceptance criteria
- repository instructions, architecture, and documented invariants
- existing public interfaces and compatibility commitments
- tests when they express established behavior

Do not search for internal planning artifacts unless the user explicitly supplies them as PR context. When intent is incomplete, record the limitation and review correctness against the observable diff, repository constraints, and stated claims.

Read the changed files and only the nearby helpers, callers, tests, schemas, or interfaces needed to understand their effects. Build a compact reviewer brief containing:

- PR identity, base SHA, and full head SHA
- changed-file list and relevant diff
- concise documented contract and known intent limitations
- applicable repository constraints
- available check and test evidence
- concrete risk signals
- candidate finding schema

Candidate finding schema:

```text
title
type
severity
file
lines
evidence
impact
trigger_or_failure_mode
suggested_action
reported_by
```

Types: `Security`, `Bug`, `Contract Deviation`, `Tests`, `Compatibility`, `Code Quality`. Severities: `Critical`, `High`, `Medium`, `Low`.

## 3. Classify Risk and Select Reviewers

Select the smallest independent reviewer set that covers the observed risk:

- `Standard`: one integrated reviewer.
- `Elevated`: integrated reviewer plus one relevant specialist.
- `Critical`: integrated reviewer plus at most two relevant specialists.

The integrated reviewer is always mandatory. It covers functional correctness, regressions, documented contract conformance, test adequacy, maintainability, and likely review friction.

Add a security specialist when the diff changes a trust boundary, including authentication, authorization, permissions, secrets, sensitive data, external input, dependency security, or comparable exposure.

Add one domain specialist when the diff contains a distinct high-impact surface the integrated reviewer cannot adequately cover, such as:

- destructive data or schema changes
- concurrency, transactions, or distributed coordination
- public API, protocol, or backwards-compatibility changes
- deployment, infrastructure, or operational safety
- another repository-specific critical invariant

Broad diffs, weak tests, or unfamiliar subsystems may raise risk, but line count alone does not justify a specialist. Do not add reviewer profiles merely because they are available.

Record the risk level, observed signals, selected reviewers, and why additional specialists were unnecessary.

## 4. Run and Inspect the Selected Reviews

Use the active runtime's native collaboration tools; never launch a nested Codex or Claude CLI process for review delegation.

Give each reviewer only the compact brief and its mission. Keep reviewers independent from one another and from any author conclusions included in chat history.

On Codex:

- spawn each reviewer with `fork_turns: "none"`
- set both `model` and `reasoning_effort` explicitly from the current spawn allowlist, sized to the review risk
- dispatch selected reviewers concurrently
- use event waits rather than repeated short polling
- inspect every final reviewer response
- request one correction for malformed or incomplete output
- if correction fails, dispatch one replacement; if that also fails, report the review as incomplete

Require either `No findings` or candidate findings in the schema. Reviewers inspect the exact PR diff, affected context, and available verification evidence. They do not post comments, modify the branch, or broaden the documented contract.

Normalize and de-duplicate candidates while preserving provenance. Reviewer output is evidence to validate, not an automatic verdict.

## 5. Validate and Disposition Findings

Validate every candidate against the diff, affected code, supplied contract, repository rules, and reproducible evidence. Assign exactly one disposition:

- `Confirmed`: evidence demonstrates a defect, regression, security or data-integrity risk, documented contract violation, or material test gap.
- `Advisory`: a supported improvement with concrete value that is not required for correctness.
- `Dismissed`: contradicted by the code or contract, not reproducible, duplicate, speculative, or outside the changed scope.

Do not report style preferences as defects unless they violate an applicable rule or create a concrete maintenance risk. Do not report a contract deviation when the supposed requirement was never provided.

## 6. Refresh the PR Before Decisions

Before finalizing, resolve the PR's current full head SHA again.

If it still equals `Initial Reviewed Commit`, that commit is the `Reviewed Commit`.

If the head changed, inspect `Initial Reviewed Commit..current head` as a fix/update delta:

- review the delta and its interaction with affected surrounding code
- confirm whether earlier findings were addressed or invalidated
- rerun a specialist only when the delta touches that specialist's risk surface
- reclassify risk and select a new reviewer set only when the delta materially broadens behavior or exposure

Repeat for subsequent commit ranges. Never present stale findings as current while any implementation delta remains uninspected. Record the current full SHA as the decision baseline only after all deltas are covered.

## 7. Present the Findings Index and Collect Decisions

If there are no confirmed findings or useful advisories, skip the decision loop and continue to the final report.

Otherwise, first present the complete numbered index of all reportable findings, ordered by disposition and severity. The user must see the whole set before deciding how to handle the first item.

For each index entry include:

- concise title and severity
- disposition: `Confirmed` or `Advisory`
- exact changed file and tight line range
- evidence from the code
- concrete impact or failure mode
- practical fix direction

Then process one finding at a time. Offer these mutually exclusive decisions:

- `Post comment`: post one PR review comment for this finding.
- `Fix in PR`: apply the smallest safe fix, run targeted verification, commit it, and push it to the PR branch.
- `Ignore`: take no external action for this finding while retaining it in the final review summary.
- `Stop`: end the decision loop; leave every undecided finding without external action.

Use the runtime's structured input tool when available. Otherwise ask the same question in concise prose and accept either one-at-a-time or compact batched answers such as `1 comment, 2 fix, 3 ignore`. Never require a particular collaboration mode.

During this loop, only record decisions. Do not post comments, edit code, commit, or push until the decision loop ends. A selected action authorizes only what its description states; it does not authorize unrelated changes.

## 8. Execute the Queued Schedule

Execute queued actions only after the decision loop finishes:

1. Resolve the current PR head again. If it changed after the decision baseline, review the new delta, refresh affected findings, and reconfirm decisions whose evidence or line locations changed.
2. Process all `Fix in PR` findings as one fix wave. Verify the target branch and write access before editing, preserve unrelated changes, load the relevant debugging/fixing skill once, apply the smallest safe fixes, run affected verification, commit, and push once.
3. Review the complete fix delta against the pre-fix head. Confirm each selected issue was addressed and inspect the delta for regressions. Rerun a specialist only when the delta touches that specialist's risk surface; reclassify only when the fix materially broadens the change.
4. If the fix-delta review produces new reportable findings, add them to a new decision loop before posting comments.
5. Resolve the PR head once more, then post each still-valid `Post comment` finding as a separate review comment at its current line location. Never combine unrelated findings into one comment.
6. Take no action for `Ignore`, `Stop`, or undecided findings.

If a queued action cannot be completed safely or the PR changes again before it executes, stop that action and report the exact reason. Do not substitute a different mutation.

Use this comment structure:

```markdown
[Severity: Critical|High|Medium|Low] {specific issue summary}

{evidence and concrete impact}

Suggested change: {clear fix direction}
```

## 9. Report the Final Review

Lead with confirmed findings and their selected outcomes. Then include, compactly:

- advisories, when useful
- actions completed, ignored, left undecided, or blocked
- questions or assumptions caused by missing intent
- initial and final reviewed commit SHAs
- risk level and selected reviewers
- verification evidence inspected or run, plus important gaps

Set `Reviewed Commit` to the final full PR head only after every PR and fix delta has been inspected. If no confirmed findings exist, say `No findings` and still state the reviewed commit, reviewer selection, and verification limitations. A clean defect review is not proof that undocumented product intent was satisfied.

## Red Flags

- Made the review depend on a particular collaboration mode or progress-plan tool
- Treated a branch name as a stable review target
- Checked out or modified the PR branch without a concrete need
- Used unavailable feature plans to manufacture product intent
- Selected specialists without observed risk signals
- Selected no integrated reviewer
- Trusted an uninspected reviewer result
- Reported candidate findings without validating them
- Reviewed only the initial head after the PR changed
- Reran every specialist after a narrow update delta
- Asked for decisions before showing the complete findings index
- Executed actions while still collecting decisions
- Combined unrelated findings into one PR comment
- Posted a comment after fixes invalidated its evidence or line location
- Treated one finding decision as permission for unrelated mutations

## Success Criteria

- Bound the review to the PR's full base and head SHAs
- Distinguished documented requirements from unknown intent
- Built a compact evidence-based reviewer brief
- Selected and inspected the smallest risk-appropriate independent reviewer set
- Validated and dispositioned all candidate findings
- Presented the complete findings index before collecting decisions
- Recorded one explicit action per reportable finding without requiring a particular collaboration mode
- Executed queued fixes before posting comments and reviewed every resulting delta
- Posted only still-valid, individually authorized comments
- Reviewed every PR update delta before finalizing
- Reported actionable findings with exact code locations and concrete impact
- Identified the final reviewed commit and verification limitations
- Performed no mutation beyond the actions explicitly selected by the user
