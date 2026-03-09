# CLAUDE.md - Claude-Specific Development Guidelines

## Purpose

This repository publishes the `feature-workflow` plugin through a Claude Code marketplace layout.

`AGENTS.md` is the default repository instruction file. Use it first for shared repository rules, then use `CLAUDE.md` for Claude-specific marketplace and maintainer guidance.

- Repository: `escarti/agentDevPrompts`
- Plugin: `feature-workflow`
- Skills: research, planning, implementing, finishing, documenting, PR review/fix, superpowers bootstrap, and subagent orchestration

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
├── prompts/  (symlinks to commands/*.md for Codex prompt compatibility)
├── scripts/
│   ├── sync_prompts_from_commands.sh
│   └── release.sh
├── skills/
│   ├── load-superpowers/
│   ├── feature-researching/
│   ├── feature-planning/
│   ├── feature-implementing/
│   ├── feature-finishing/
│   ├── feature-documenting/
│   ├── feature-pr-reviewing/
│   ├── feature-pr-fixing/
│   └── use-sub-agent/
├── docs/
│   ├── ai/ongoing/
│   └── plans/
├── README.md
└── PUBLISHING.md
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

`use-sub-agent` is standalone and can be used whenever task delegation to headless Codex subagents is needed.

## Naming Conventions

Avoid command/skill collisions.

- Skills: gerund form (`feature-planning`)
- Commands: imperative form (`/feature-plan`)

Command files should stay thin wrappers that invoke their corresponding skill.
Prompt compatibility is maintained by symlinking `prompts/*.md` to `commands/*.md` via `./scripts/sync_prompts_from_commands.sh`.

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

Before creating any release tag (or any new git tag intended as a release), update `CHANGELOG.md` for that version and synchronize all version locations:

1. Git tag: `vX.Y.Z`
2. `.claude-plugin/plugin.json` -> `version`
3. `.claude-plugin/marketplace.json` -> `metadata.version`
4. `.claude-plugin/marketplace.json` -> `plugins[0].version`

If any version is mismatched, fix files first, commit, then tag.

## Release Checklist

- Validate all changed skills/commands in local Claude Code
- Ensure README, AGENTS, and PUBLISHING docs still match behavior
- Update `CHANGELOG.md` for the release version
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

- `AGENTS.md`: default repository instructions and Codex workflow guardrails
- `README.md`: end-user install and usage
- `PUBLISHING.md`: release procedure details
- `CLAUDE.md` (this file): Claude-specific marketplace and maintainer rules
