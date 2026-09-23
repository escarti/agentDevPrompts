# AGENTS.md

## Scope

Codex agent instructions for this repository. This repo is a local skill library for Codex workflows.

## Codex-First Rules

- Do not assume Claude marketplace or plugin flows.
- `AGENTS.md` is the default repository instruction file for Codex workflows. Read it first.
- If the user asks to deploy a new Claude marketplace version, read `AGENTS.md` first, then read `CLAUDE.md` and follow those Claude-specific release instructions exactly.
- For any release or git tag creation, update `CHANGELOG.md` in the same change before committing/tagging.
- Treat `skills/*/SKILL.md` as the source of truth.
- If a user names a skill (or task clearly matches one), load that skill and follow it.
- Keep command files thin if edited (`commands/*.md`); workflow logic belongs in skills.

## Workflow Skill Dependencies

Installed plugins expose their skills through Codex. Each workflow invokes only the dependency it needs at its point of use. `feature-researching` invokes the installed `grilling` skill to conduct the interview. Select native collaboration tools from the active runtime.

| Feature workflow | Dependency | Invocation point |
| --- | --- | --- |
| `feature-researching` | `grilling` | Interview; then write the agreed Z01 specification |
| `feature-planning` | `superpowers:writing-plans` | When producing the Z02 implementation plan |
| `feature-implementing` | `superpowers:subagent-driven-development` or `superpowers:executing-plans` | After the user selects execution mode |
| `feature-pr-fixing` | `superpowers:systematic-debugging` | Only for queued fixes |
| `fixing-small-issues` | `superpowers:systematic-debugging`, `superpowers:test-driven-development`, `superpowers:verification-before-completion` | Inside the corresponding isolated phase agent |
| `feature-qa-review` | None | Use native collaboration tools |
| `feature-pr-reviewing` | None | Use native collaboration tools |
| `feature-finishing` | None | Standalone |
| `feature-documenting` | None | Standalone |

`fixing-small-issues` uses no Z artifacts, creates or resumes its bugfix branch before Phase 1, and excludes new features. If Phase 1 diagnoses a feature gap, stop before Phase 2 and route the work to `feature-workflow:feature-researching`.

## Workflow Artifacts

- Use `docs/ai/ongoing/` for temporary workflow files.
- Common artifacts: `Z01_*`, `Z02_*`, `Z03_*`, `Z04_*`, `Z05_*`.
- Additional review artifact: `Z06_{feature}_qa_review.md`.
- Implementation evidence: `Z98_{feature}_implementation_report.md`; temporary Superpowers batch plans may also use `Z98_*_batch_*_plan.md`.
- Feature slugs: `snake_case` (max 50 chars).
- PR slugs: `kebab-case` (max 50 chars).
