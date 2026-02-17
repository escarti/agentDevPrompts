# AGENTS.md

## Scope

Codex agent instructions for this repository. This repo is a local skill library for Codex workflows.

## Codex-First Rules

- Do not assume Claude marketplace or plugin flows.
- If the user asks to deploy a new Claude marketplace version, read `CLAUDE.md` and follow those release instructions exactly.
- For any release or git tag creation, update `CHANGELOG.md` in the same change before committing/tagging.
- Treat `skills/*/SKILL.md` as the source of truth.
- If a user names a skill (or task clearly matches one), load that skill and follow it.
- Keep command files thin if edited (`commands/*.md`); workflow logic belongs in skills.

## Skill Loading Rule

Before feature skills that depend on superpowers, run `load-superpowers` first.

Requires `load-superpowers` first:
- `feature-planning`
- `feature-implementing`
- `feature-finishing`
- `feature-pr-reviewing`
- `feature-pr-fixing`

Standalone:
- `feature-researching`
- `feature-documenting`

## Workflow Artifacts

- Use `docs/ai/ongoing/` for temporary workflow files.
- Common artifacts: `Z01_*`, `Z01_CLARIFY_*`, `Z02_*`, `Z03_*`, `Z04_*`, `Z05_*`.
- Feature slugs: `snake_case` (max 50 chars).
- PR slugs: `kebab-case` (max 50 chars).
