# QA-Gated Finishing and Publication Design

**Date:** 2026-07-22
**Status:** Approved for implementation planning

## Problem

The documented feature workflow places `feature-qa-review` between implementation and finishing, but `feature-implementing` currently ends by saying the work is ready for optional finishing. This permits an agent to skip QA and jump directly to `feature-finishing`.

`feature-qa-review` and `feature-finishing` also duplicate bug, security, plan-conformance, test, maintainability, and documentation review. Neither skill currently provides a binding clean-QA handoff, and finishing does not own the requested commit, push, and ready-for-review PR publication flow.

## Decision

Use a hard-gated workflow with one owner for each concern:

```text
feature-implementing
  -> feature-qa-review
  -> accepted PASS verdict
  -> feature-finishing
  -> documentation finalization commit
  -> final publication approval
  -> branch push
  -> ready-for-review pull request
```

- `feature-qa-review` owns fresh code, security, tests, plan-conformance, and maintainability review.
- `feature-finishing` owns documentation consistency, change recording, final verification, commit preparation, push, and PR creation.
- `feature-implementing` owns the mandatory handoff into QA and must never call finishing directly.

## Implementation-to-QA Handoff

After the implementation completion gate passes, `feature-implementing` must invoke `feature-qa-review` on the current feature branch. Its completion language must name QA as the only next workflow stage and explicitly prohibit direct handoff to `feature-finishing`.

Implementation remains incomplete as an end-to-end workflow until QA returns an accepted `PASS`. A blocked, interrupted, or unavailable QA run returns control without launching finishing.

## QA Gate

QA must rebuild its context from the current branch and source artifacts. It must record the reviewed branch and commit SHA in `Z06_{feature}_qa_review.md`.

The final QA verdict is one of:

- `PASS`: every isolated review profile returned `No findings`, required verification passed, and the user explicitly accepted the result.
- `BLOCKED`: one or more findings exist, verification failed, the decision loop stopped with unresolved work, or the user did not accept the result.

Documentation-consistency review moves out of QA and into finishing. QA retains these isolated profiles:

1. Bug hunter
2. Security reviewer
3. Plan-conformance reviewer
4. Test-gap reviewer
5. Maintainability / reviewer-likelihood reviewer

Any QA finding blocks finishing, regardless of severity or disposition. If findings are fixed or branch code changes for any other reason, the complete fresh QA review must run again. A prior `PASS` cannot be reused for a changed code revision.

When QA reaches `PASS`, it must ask for explicit acceptance. Only an accepted `PASS` may invoke `feature-finishing`.

## Finishing Gate

`feature-finishing` is a lighter post-QA workflow, not a second code review. Before doing documentation work, it must verify:

- the current branch is a non-`main` feature branch;
- a matching `Z06_{feature}_qa_review.md` exists;
- the Z06 verdict is `PASS` and records user acceptance;
- the accepted QA commit matches the current code revision;
- no unresolved QA findings remain.

If those checks fail, finishing must stop and route back to `feature-qa-review`.

Finishing must scan the documentation and repository-facing surfaces affected by the feature, including when relevant:

- `README.md`
- `AGENTS.md`
- `CLAUDE.md`
- `PUBLISHING.md`
- `CHANGELOG.md`
- command wrappers and prompt links
- skill metadata and plugin metadata
- user-facing API, install, configuration, migration, and workflow documentation

It must compare those surfaces with the accepted implementation, record material user/developer-facing changes, and correct inconsistencies. Documentation-only changes made during finishing do not invalidate QA. Any non-documentation implementation change does invalidate QA and must stop finishing until a fresh QA run passes and is accepted.

Finishing records its outcome in `Z05_{feature}_finish.md`, including the accepted QA commit, documentation files checked, drift found, changes applied, verification evidence, publication approval, final commit, pushed branch, and PR URL.

## Commit and Publication

Before publication, finishing must:

1. Inspect the worktree and distinguish workflow-owned changes from unrelated user changes.
2. Stage only intended feature and documentation files.
3. Run fresh, relevant verification and inspect the result.
4. Create an isolated documentation/finalization commit when finishing produced changes.
5. Present a publication summary containing branch, base, commits, verification, documentation updates, and proposed PR title/body.
6. Ask for explicit final publication approval.

After approval, finishing must push the current feature branch without force-pushing and open a ready-for-review PR against `main`. It should prefer the available GitHub integration and use authenticated `gh` as a fallback. If authentication, remote resolution, push, or PR creation fails, it must stop with the completed local work intact and report the exact blocker.

The PR body must summarize:

- what changed and why;
- user or developer impact;
- QA verdict and reviewed commit;
- documentation updates;
- verification performed;
- relevant tracker references.

Finishing must not clean up the branch or worktree after opening the PR because follow-up review changes may still be required.

## Documentation and Metadata Updates

Repository guidance must describe the enforced chain rather than merely list the stages. At minimum, update the workflow descriptions in `README.md` and any skill metadata whose triggering language still permits finishing directly after implementation.

Command files remain thin; orchestration logic stays in `skills/*/SKILL.md`.

## Validation

Skill behavior will be validated with a before/after pressure scenario:

- Baseline: give an agent completed implementation and tempt it to jump directly to finishing; record whether the current skills permit the skip.
- Updated behavior: repeat with the revised skills and require the agent to launch QA first.
- Gate failure: provide a Z06 with findings or a stale reviewed commit and require finishing to stop.
- Clean path: provide an accepted clean Z06 and require finishing to run documentation checks, request publication approval, then push and open a ready-for-review PR.
- Scope safety: include unrelated worktree changes and require finishing not to stage them.

Success requires the workflow to reject every direct implementation-to-finishing path and every publication attempt without an accepted clean QA verdict and explicit final approval.
