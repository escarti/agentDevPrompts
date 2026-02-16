# CLAUDE.md - Development Guidelines

## Purpose

This repository publishes the `feature-workflow` plugin through a Claude Code marketplace layout.

- Repository: `escarti/agentDevPrompts`
- Plugin: `feature-workflow`
- Skills: research, planning, implementing, finishing, documenting, PR review/fix, and superpowers bootstrap

## Current Repository Layout

```text
agentDevPrompts/
├── .claude-plugin/
│   ├── plugin.json
│   └── marketplace.json
├── commands/
│   ├── feature-research.md
│   ├── feature-plan.md
│   ├── feature-implement.md
│   ├── feature-finish.md
│   ├── feature-document.md
│   ├── feature-prreview.md
│   └── feature-prfix.md
├── skills/
│   ├── load-superpowers/
│   ├── feature-researching/
│   ├── feature-planning/
│   ├── feature-implementing/
│   ├── feature-finishing/
│   ├── feature-documenting/
│   ├── feature-pr-reviewing/
│   └── feature-pr-fixing/
├── docs/
│   ├── ai/ongoing/
│   └── plans/
├── README.md
├── PUBLISHING.md
└── release.sh
```

## Skill Dependency Rules

`feature-*` skills that depend on superpowers must bootstrap with `load-superpowers` first.

- Standalone:
  - `feature-researching`
  - `feature-documenting`
- Requires `load-superpowers` first:
  - `feature-planning`
  - `feature-implementing`
  - `feature-finishing`
  - `feature-pr-reviewing`
  - `feature-pr-fixing`

## Naming Conventions

Avoid command/skill collisions.

- Skills: gerund form (`feature-planning`)
- Commands: imperative form (`/feature-plan`)

Command files should stay thin wrappers that invoke their corresponding skill.

## Workflow Artifacts

Temporary artifacts are written to `docs/ai/ongoing/`.

- `Z01_{feature}_research.md`
- `Z01_CLARIFY_{feature}_research.md`
- `Z02_{feature}_plan.md`
- `Z03_*`, `Z04_*`, `Z05_*` for PR/finishing flows

Filename sanitizer patterns:

- Feature names: `snake_case`, max 50 chars
- PR titles: `kebab-case`, max 50 chars

## Release Rules (Critical)

Before tagging a release, synchronize all version locations:

1. Git tag: `vX.Y.Z`
2. `.claude-plugin/plugin.json` -> `version`
3. `.claude-plugin/marketplace.json` -> `metadata.version`
4. `.claude-plugin/marketplace.json` -> `plugins[0].version`

If any version is mismatched, fix files first, commit, then tag.

## Release Checklist

- Validate all changed skills/commands in local Claude Code
- Ensure README and PUBLISHING docs still match behavior
- Sync the 3 version fields and planned git tag
- Commit changes
- Push branch
- Create and push annotated tag `vX.Y.Z`
- Verify tagged commit contains synchronized versions

## Skill Quality Expectations

When changing skills, follow RED -> GREEN -> REFACTOR discipline:

- RED: reproduce failure mode without the skill guidance
- GREEN: minimal fix in the skill to address the failure
- REFACTOR: tighten wording and remove ambiguity

Keep skill descriptions short enough to force reading the full `SKILL.md`, not guessing from metadata.

## Documentation Boundaries

- `README.md`: end-user install and usage
- `PUBLISHING.md`: release procedure details
- `CLAUDE.md` (this file): maintainer guardrails and non-negotiable rules

