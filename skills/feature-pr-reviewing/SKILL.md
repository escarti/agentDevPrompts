---
name: feature-pr-reviewing
description: Review an independently submitted pull request using a commit-bound, risk-adaptive set of reviewers. Use for finding defects in a PR; do not use to certify undocumented product intent or to implement fixes.
---

# Review Pull Request

Review the supplied PR as a standalone, read-only task. Bind the review to exact commits, select only the reviewers justified by the changed surface, validate their candidate findings, and report actionable defects. The PR description and linked requirements may supply a contract, but never infer or certify undocumented product intent.

## Review Invariants

```text
UNRESOLVED PR TARGET OR HEAD COMMIT -> REVIEW BLOCKED
FAILED, MISSING, OR UNINSPECTED SELECTED REVIEWER -> REVIEW INCOMPLETE
UNREVIEWED PR DELTA -> REVIEW OUTDATED
CANDIDATE FINDING WITHOUT VALIDATION -> DO NOT REPORT AS CONFIRMED
NO DOCUMENTED REQUIREMENT -> NO CLAIM OF REQUIREMENT CONFORMANCE
NO EXPLICIT WRITE REQUEST -> DO NOT POST COMMENTS OR CHANGE CODE
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

The required `load-superpowers` bootstrap must have loaded `superpowers:using-superpowers` before this workflow begins. Use the current runtime's native subagent tools; never launch a nested Codex or Claude CLI process for review delegation.

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

## 6. Handle PR Updates Without Losing Review Coverage

Before finalizing, resolve the PR's current full head SHA again.

If it still equals `Initial Reviewed Commit`, that commit is the `Reviewed Commit`.

If the head changed, inspect `Initial Reviewed Commit..current head` as a fix/update delta:

- review the delta and its interaction with affected surrounding code
- confirm whether earlier findings were addressed or invalidated
- rerun a specialist only when the delta touches that specialist's risk surface
- reclassify risk and select a new reviewer set only when the delta materially broadens behavior or exposure

Repeat for subsequent commit ranges. Never claim the latest PR is reviewed while any implementation delta remains uninspected. Record the final full SHA as `Reviewed Commit` only after all deltas are covered.

## 7. Report the Review

Lead with confirmed findings, ordered by severity. For each finding include:

- concise title and severity
- exact changed file and tight line range
- evidence from the code
- concrete impact or failure mode
- practical fix direction

Then include, compactly:

- advisories, when useful
- questions or assumptions caused by missing intent
- initial and final reviewed commit SHAs
- risk level and selected reviewers
- verification evidence inspected or run, plus important gaps

If no confirmed findings exist, say `No findings` and still state the reviewed commit, reviewer selection, and verification limitations. A clean defect review is not proof that undocumented product intent was satisfied.

Keep the task read-only unless the user explicitly asks to post comments or modify code. Treat a later posting or fix request as a separate task rather than silently extending this review.

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
- Posted PR comments, changed code, or created workflow artifacts without an explicit request

## Success Criteria

- Bound the review to the PR's full base and head SHAs
- Distinguished documented requirements from unknown intent
- Built a compact evidence-based reviewer brief
- Selected and inspected the smallest risk-appropriate independent reviewer set
- Validated and dispositioned all candidate findings
- Reviewed every PR update delta before finalizing
- Reported actionable findings with exact code locations and concrete impact
- Identified the final reviewed commit and verification limitations
- Left the PR and working tree unchanged unless the user explicitly requested a mutation
