# CLAUDE.md - Claude-Specific Development Guidelines

## Purpose

This repository publishes the `feature-workflow` plugin through a Claude Code marketplace layout.

`AGENTS.md` is the default repository instruction file. Use it first for shared repository rules, then use `CLAUDE.md` for Claude-specific marketplace and maintainer guidance.

- Repository: `escarti/agentDevPrompts`
- Plugin: `feature-workflow`
- Skills: research, planning, implementing, QA review, finishing, documenting, PR review/fix, and streamlined small-issue fixing

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
│   ├── feature-qa-review.md
│   ├── feature-finish.md
│   ├── feature-document.md
│   ├── feature-prreview.md
│   ├── feature-prfix.md
│   └── fix-small-issue.md
├── prompts/  (symlinks to commands/*.md for Codex prompt compatibility)
├── scripts/
│   ├── sync_prompts_from_commands.sh
│   └── release.sh
├── skills/
│   ├── feature-researching/
│   ├── feature-planning/
│   ├── feature-implementing/
│   ├── feature-qa-review/
│   ├── feature-finishing/
│   ├── feature-documenting/
│   ├── feature-pr-reviewing/
│   ├── feature-pr-fixing/
│   └── fixing-small-issues/
├── docs/
│   ├── ai/ongoing/
│   └── plans/
├── README.md
└── PUBLISHING.md
```

## Skill Dependency Rules

Superpowers is installed through the host runtime's plugin or marketplace flow. Repository skills invoke only the named capability when it is needed; they do not activate plugins or use a shared bootstrap layer.

| Feature workflow | Superpowers dependency | Invocation point |
| --- | --- | --- |
| `feature-researching` | `superpowers:brainstorming` | Only when deeper product/design refinement is needed |
| `feature-planning` | `superpowers:writing-plans` | When producing the Z02 implementation plan |
| `feature-implementing` | `superpowers:subagent-driven-development` or `superpowers:executing-plans` | After the user selects execution mode |
| `feature-pr-fixing` | `superpowers:systematic-debugging` | Only for queued fixes |
| `fixing-small-issues` | `superpowers:systematic-debugging`, `superpowers:test-driven-development`, `superpowers:verification-before-completion` | Inside the corresponding isolated phase agent |
| `feature-qa-review` | None | Use native collaboration tools |
| `feature-pr-reviewing` | None | Use native collaboration tools |
| `feature-finishing` | None | Standalone |
| `feature-documenting` | None | Standalone |

Delegating workflows use the current runtime's native collaboration tools. Do not launch nested Codex CLI processes for delegation.

`fixing-small-issues` keeps its coordinator light: `superpowers:systematic-debugging` loads inside Phase 1 sub-agents, while `superpowers:test-driven-development` and `superpowers:verification-before-completion` load inside Phase 2 sub-agents. New features are out of scope; when Phase 1 diagnoses a feature gap, stop before Phase 2 and route the work to `feature-workflow:feature-researching`.

## Naming Conventions

Avoid command/skill collisions.

- Skills: gerund form (`feature-planning`)
- Commands: imperative form (`/feature-plan`)

Command files should stay thin wrappers that invoke their corresponding skill.
Prompt compatibility is maintained by symlinking `prompts/*.md` to `commands/*.md` via `./scripts/sync_prompts_from_commands.sh`.

## Workflow Artifacts

Temporary artifacts are written to `docs/ai/ongoing/`.

- `Z01_{feature}_research.md`
- `Z02_{feature}_plan.md`
- `Z02_CLARIFY_{feature}_plan.md`
- `Z03_*`, `Z04_*`, `Z05_*` for PR/finishing flows
- `Z06_{feature}_qa_review.md` for the commit-bound QA verdict, verification evidence, findings, and user acceptance
- `Z98_{feature}_implementation_report.md` for implementation results, phase approvals, and reusable commit-bound verification evidence
- `Z98_{feature}_batch_{phase}_{batch}_plan.md` for temporary Superpowers batch adaptation

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
