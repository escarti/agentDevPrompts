---
name: feature-finishing
description: Use after feature-qa-review returns an explicitly accepted PASS for the current code revision.
---

# Feature Workflow: Finish and Publish Feature

## YOU ARE READING THIS SKILL RIGHT NOW

**STOP. Before doing ANYTHING else:**

1. Create the progress plan below.
2. Mark Step 1 as `in_progress`.
3. Confirm the current branch is not `main`.
4. Validate an accepted, commit-bound QA `PASS` before changing documentation.

This is a lightweight post-QA documentation and publication gate. It is not a second bug, security, test-gap, plan-conformance, or PR-style code review.

## MANDATORY FIRST ACTION: Create Progress Plan

```typescript
update_plan({
  "explanation": "Tracking feature finishing and publication workflow",
  "plan": [
    {"step": "Step 1: Validate the feature branch and accepted QA PASS", "status": "in_progress"},
    {"step": "Step 2: Load repository instructions and feature context", "status": "pending"},
    {"step": "Step 3: Build the documentation impact matrix", "status": "pending"},
    {"step": "Step 4: Audit change recording and documentation consistency", "status": "pending"},
    {"step": "Step 5: Apply documentation-only corrections", "status": "pending"},
    {"step": "Step 6: Verify QA freshness and run final checks", "status": "pending"},
    {"step": "Step 7: Create Z05 finish documentation", "status": "pending"},
    {"step": "Step 8: Commit intended finalization changes", "status": "pending"},
    {"step": "Step 9: Present the publication summary and obtain approval", "status": "pending"},
    {"step": "Step 10: Push and open a ready-for-review PR", "status": "pending"},
    {"step": "Step 11: Record and push the publication receipt", "status": "pending"}
  ]
})
```

After each step, mark it completed and move `in_progress` to the next step.

## Gate Invariant

```text
NO ACCEPTED QA PASS -> NO FINISHING
STALE REVIEWED CODE COMMIT -> RETURN TO COMPLETE FRESH QA
NON-DOCUMENTATION IMPLEMENTATION CHANGE -> RETURN TO COMPLETE FRESH QA
NO EXPLICIT PUBLICATION APPROVAL -> NO PUSH AND NO PR
NEVER STAGE UNRELATED USER CHANGES
NEVER FORCE-PUSH
OPEN A READY-FOR-REVIEW PR, NOT A DRAFT
```

## Workflow Steps

### Step 1: Validate the Feature Branch and Accepted QA PASS

Run:

```bash
git branch --show-current
git rev-parse HEAD
git status --short
git diff main --name-only
```

If the current branch is `main`, stop and report:

```text
Cannot run feature-finishing from main. Switch to the feature branch first.
```

Locate the matching `{ONGOING_DIR}/Z06_{feature}_qa_review.md`. Require all of:
- `Verdict: PASS`
- `User Acceptance: Accepted`
- a full `Reviewed Commit` SHA
- no findings recorded for that QA run
- successful required verification recorded
- matching feature branch and feature slug

At finishing entry, verify the Z06 `Reviewed Commit` is an ancestor of HEAD:

```bash
git merge-base --is-ancestor <reviewed-commit> HEAD
git diff --name-only <reviewed-commit>..HEAD
git diff --name-only
```

Classify committed history separately from uncommitted worktree state:
- every commit after the reviewed commit must be finishing-owned documentation/publication work
- an unrelated, feature-implementation, or provenance-ambiguous committed descendant blocks finishing because it would be included in the push; ask the user to isolate or rebase that history
- uncommitted paths may be classified as finishing-owned, clearly unrelated user work, feature implementation work, or provenance-ambiguous
- feature implementation or provenance-ambiguous uncommitted changes block finishing

Documentation/publication-only commits created by a prior finishing attempt are valid and allow the workflow to resume.

If Z06 is missing, `BLOCKED`, not accepted, contains findings, the reviewed commit is not an ancestor of HEAD, or post-QA history contains implementation changes:
- stop immediately
- do not audit or edit documentation
- route back to a complete fresh `feature-qa-review`
- do not treat user urgency or prior test results as an exception

Clearly unrelated user changes may remain in the worktree only when their provenance and exclusion are unambiguous. Record them in the publication summary, exclude them from documentation comparisons and verification claims, and never stage, discard, or rewrite them. If provenance or QA freshness is ambiguous, stop and ask the user to isolate the change before continuing.

Resumption rules:
- after a documentation/finalization commit, resume at the earliest incomplete finishing step without requiring new QA
- after a successful push but failed PR creation, preserve the pushed branch and retry PR discovery/creation after prerequisites recover
- when a PR already exists, verify its repository, head branch, and base branch are the intended values before updating it
- never repeat, amend, or discard a successful finishing commit merely to reconstruct state

### Step 2: Load Repository Instructions and Feature Context

Read in this order:
1. `AGENTS.md`
2. `CLAUDE.md` when it exists
3. `README.md` when it exists
4. `PUBLISHING.md` when it exists
5. accepted `Z06_{feature}_qa_review.md`
6. `Z01_{feature}_research.md` when present
7. `Z02_{feature}_plan.md` and answered plan clarification when present
8. tracker requirements when tracker context is authoritative
9. `Z99_implementation_status.md` in local-plan mode

Extract:
- feature name and slug
- `ONGOING_DIR`
- accepted QA commit
- user-visible and developer-visible changes
- repository documentation conventions
- required verification commands
- tracker references for the PR body

### Step 3: Build the Documentation Impact Matrix

Use the branch diff, feature contract, and repository instructions to map each material change to affected documentation.

Inspect these surfaces when relevant:

| Surface | Check for drift |
|---|---|
| `README.md` | public behavior, workflows, usage, install, configuration |
| `AGENTS.md` | repository rules and Codex workflow requirements |
| `CLAUDE.md` | Claude-specific repository and marketplace behavior |
| `PUBLISHING.md` | release, installation, metadata, and publication rules |
| `CHANGELOG.md` | material unreleased user/developer-facing changes |
| `commands/*.md` | thin wrappers still point to the correct source skill |
| `prompts/*` | links or generated prompt mirrors remain valid |
| `skills/*/agents/openai.yaml` | UI metadata matches current triggering intent |
| plugin metadata | versioned descriptions and exposed capability lists remain consistent |
| API/install/config/migration docs | changed contracts and required operator actions are recorded |

For every changed behavior, record:
- documentation surface checked
- update required: `yes` or `no`
- evidence or reason
- intended file when an update is required

Do not change documentation merely to create churn. `No update required` is valid only with a concrete reason.

### Step 4: Audit Change Recording and Documentation Consistency

Compare all impacted surfaces against the accepted implementation.

Check for:
- obsolete workflow ordering or behavior
- missing new commands, options, constraints, or migration steps
- contradictions between repository instruction files
- command wrappers that contain workflow logic instead of delegating to skills
- broken prompt links or stale UI metadata
- missing unreleased `CHANGELOG.md` entries when the change is material
- version metadata drift when a release is in scope

This step owns documentation consistency. Do not repeat QA's bug, security, test-gap, plan-conformance, or maintainability profiles.

### Step 5: Apply Documentation-Only Corrections

Apply the smallest edits needed to remove confirmed drift and record material changes.

Allowed finishing edits are documentation and publication metadata only, including Markdown documentation, command wrappers, prompt links, skill UI metadata, changelog entries, and release metadata when explicitly in scope.

If the audit reveals that implementation code, runtime configuration, tests, schemas, or executable workflow logic must change:
- stop finishing
- do not make the non-documentation change here
- report that the accepted QA verdict is no longer sufficient
- route the work back through implementation/fixing and a complete fresh QA review

After editing, inspect `git status --short` and `git diff`. Separate finishing-owned paths from unrelated user changes. Never use `git add -A` in a mixed worktree.

### Step 6: Verify QA Freshness and Run Final Checks

First verify QA freshness:
- the accepted QA commit remains an ancestor of HEAD
- all changes after the accepted QA commit are documentation/publication-only
- no feature-owned or provenance-ambiguous uncommitted non-documentation implementation changes exist
- every clearly unrelated user change is identified, excluded from finishing scope, and preserved untouched

If any post-QA change affects implementation behavior, stop and require complete fresh QA.

Then run fresh relevant verification:
- always run `git diff --check`
- run repository-required documentation, link, metadata, generation, or validation commands
- run project checks required by AGENTS.md, the plan, tracker, or accepted QA record when publication depends on them
- inspect full output and exit status

Do not claim readiness, commit, push, or create a PR when required verification fails.

### Step 7: Create Z05 Finish Documentation

Create `{ONGOING_DIR}/Z05_{feature}_finish.md` before the finalization commit.

Required format:

```markdown
# Feature Finish: {Feature Name}

**Date**: {date}
**Branch**: {branch}
**Accepted QA Commit**: {full SHA}
**QA Artifact**: {path to Z06}
**QA Verdict**: PASS
**QA User Acceptance**: Accepted

## Documentation Consistency
| Surface | Checked | Drift Found | Action |
|---|---|---|---|
| {path or category} | Yes | Yes | {change or reason} |

## Change Recording
- **CHANGELOG**: Updated | Not required — {reason}
- **Migration or operator notes**: {details or not required reason}

## Verification
- `{command}`: PASS — {evidence}

## Publication
- **Approval**: Pending
- **Finalization Commit**: Pending
- **Pushed Branch**: Pending
- **PR State**: Pending ready-for-review PR
- **PR URL**: Pending
```

### Step 8: Commit Intended Finalization Changes

Inspect scope before staging:

```bash
git status -sb
git diff --name-only
git diff
```

Rules:
- identify every path owned by this finishing run
- stage explicit paths only
- do not stage unrelated user changes
- do not use `git add -A` when the worktree is mixed
- do not amend or rewrite implementation commits unless the user explicitly requested it
- create one isolated documentation/finalization commit when finishing produced changes
- if no finishing change exists, retain the accepted QA commit as the publication head

Update the Z05 `Finalization Commit` field before committing when the final SHA can be derived deterministically; otherwise record it in the publication receipt in Step 11.

After committing, run `git status -sb` and verify all remaining changes are intentionally excluded.

### Step 9: Present Publication Summary and Obtain Approval

Require GitHub publication prerequisites before asking for approval:

```bash
gh --version
gh auth status
git remote get-url origin
git branch --show-current
```

Resolve:
- head branch: current feature branch
- base branch: `main`
- remote repository
- existing PR for the current head branch, if any

If an existing PR is found, verify it targets the resolved repository, uses the current feature branch as head, and uses `main` as base before proposing any mutation.

Present:
- branch and base
- implementation and finalization commits
- accepted QA commit and verdict
- documentation surfaces checked and changed
- verification commands and outcomes
- intentionally excluded worktree changes
- proposed PR title
- proposed PR body
- action: create a ready-for-review PR, or mark the existing draft ready

Then ask:

```text
Publish this branch and open the ready-for-review PR?
1) Approve publication
2) Do not publish
```

No approval means no push and no PR mutation. Leave local commits intact.

### Step 10: Push and Open a Ready-for-Review PR

Only after explicit `Approve publication`:

1. Push without force:
   ```bash
   git push -u origin <current-feature-branch>
   ```
2. Prefer the available GitHub integration for PR creation.
3. If connector coverage is unavailable or cannot resolve the repository/head cleanly, use authenticated `gh`.
4. Create the PR against `main` in ready-for-review state. With `gh pr create`, omit `--draft`.
5. If a PR already exists, do not create a duplicate. If it is a draft, mark it ready only as described in the approved publication summary.
6. Never force-push.

The PR body must cover:
- what changed and why
- user or developer impact
- accepted QA verdict and reviewed commit
- documentation changes
- verification evidence
- relevant tracker links or identifiers

If authentication, remote resolution, push, or PR creation fails:
- stop
- preserve local commits, branch, and worktree
- report the exact failed command or connector action
- do not claim publication succeeded

Do not clean up the branch or worktree after opening the PR; reviewers may request changes.

### Step 11: Record and Push the Publication Receipt

After the PR exists:
1. Update Z05 with `Approval: Approved`, the finalization commit, pushed branch, `PR State: Ready for review`, and the PR URL.
2. Inspect `git status --short` and `git diff -- <Z05 path>`.
3. Run `git diff --check -- <Z05 path>`.
4. Commit only the updated Z05 as a publication receipt when the artifact is tracked.
5. Verify the receipt commit contains only Z05.
6. Push that receipt commit without force.
7. Confirm the ready-for-review PR includes the receipt commit.

If the ongoing artifact directory is intentionally ignored or Z05 is not tracked, report the publication details without forcing it into version control.

## Red Flags

- Started without an accepted Z06 `PASS`
- Accepted a Z06 containing any finding
- Ignored a stale `Reviewed Commit`
- Rejected valid documentation-only finishing commits when resuming after the reviewed commit
- Allowed an unrelated committed descendant of the reviewed commit into the publication branch
- Repeated QA's bug, security, test-gap, plan, or maintainability reviews
- Changed implementation code, tests, schemas, runtime configuration, or executable workflow logic during finishing
- Failed to route non-documentation work back through fresh QA
- Skipped affected documentation surfaces without recording a reason
- Failed to record a material change in CHANGELOG or migration docs
- Used `git add -A` in a mixed worktree
- Staged, discarded, or overwrote unrelated user changes
- Committed or published with failing verification
- Pushed or mutated a PR without explicit publication approval
- Force-pushed
- Opened a draft instead of a ready-for-review PR
- Created a duplicate PR
- Cleaned up the branch or worktree after publication

## Common Rationalizations

| Excuse | Reality |
|--------|---------|
| "Finishing can catch anything QA missed." | No. Finishing owns documentation consistency; code concerns return to fresh QA. |
| "The reviewed commit is close enough." | No. The gate is commit-bound; non-documentation drift requires complete fresh QA. |
| "HEAD must always equal the reviewed commit." | Only at the start of the first finishing attempt. On resume, the reviewed commit must be an ancestor and all later feature-owned changes must be documentation/publication-only. |
| "This tiny code fix does not need QA again." | Any implementation change invalidates the accepted verdict. |
| "The user asked for a PR, so push approval is implied." | No. Publication requires the explicit final approval in Step 9. |
| "A draft PR is safer by default." | The approved workflow requires ready-for-review after clean QA and final approval. |
| "Staging everything is faster." | Unrelated user changes must never enter the feature commit or PR. |
| "The PR URL cannot be recorded after the commit." | Use the Step 11 publication receipt without rewriting prior commits. |

## Success Criteria

- Started on a feature branch with a matching accepted Z06 `PASS`
- Verified the accepted QA commit was an ancestor of HEAD and every committed descendant was finishing-owned documentation/publication work
- Audited every affected documentation surface and recorded reasons
- Corrected only documentation and publication metadata drift
- Routed any required implementation change back to complete fresh QA
- Ran fresh verification and inspected results
- Created Z05 with QA, documentation, verification, commit, and publication evidence
- Staged only intended paths and preserved unrelated changes
- Obtained explicit final publication approval
- Pushed without force
- Opened or updated one ready-for-review PR against `main`
- Preserved the branch and worktree for reviewer follow-up
