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

## Skill Loading Rule

Before repository workflows that depend on Superpowers, run `load-superpowers` first.

Requires `load-superpowers` first:
- `feature-researching`
- `feature-planning`
- `feature-implementing`
- `feature-qa-review`
- `feature-finishing`
- `feature-pr-reviewing`
- `feature-pr-fixing`
- `fixing-small-issues`

Standalone:
- `feature-documenting`

`fixing-small-issues` uses no Z artifacts, creates or resumes its bugfix branch before Phase 1, and excludes new features. If Phase 1 diagnoses a feature gap, stop before Phase 2 and route the work to `feature-workflow:feature-researching`.

## Workflow Artifacts

- Use `docs/ai/ongoing/` for temporary workflow files.
- Common artifacts: `Z01_*`, `Z02_*`, `Z03_*`, `Z04_*`, `Z05_*`.
- Additional review artifact: `Z06_{feature}_qa_review.md`.
- Implementation evidence: `Z98_{feature}_implementation_report.md`; temporary Superpowers batch plans may also use `Z98_*_batch_*_plan.md`.
- Feature slugs: `snake_case` (max 50 chars).
- PR slugs: `kebab-case` (max 50 chars).
