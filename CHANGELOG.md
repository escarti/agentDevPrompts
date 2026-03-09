# Changelog

All notable changes to this project are documented in this file.

The format is based on Keep a Changelog and this project follows semantic versioning for git tags.

## [Unreleased]

### Added
- None.

### Changed
- None.

### Fixed
- None.

## [1.19.0] - 2026-03-09

### Added
- None.

### Changed
- Strengthened `skills/feature-pr-reviewing/SKILL.md` so the numbered findings index is an explicit blocking prerequisite before any `Finding 1` prompt.
- Updated `skills/feature-finishing/SKILL.md` to require a numbered findings index alongside the aggregate summary before any per-issue interaction starts.

### Fixed
- Prevented Plan mode review loops from asking about `Finding 1` or `Issue 1` before the user has seen the full findings list context.

## [1.18.0] - 2026-03-09

### Added
- None.

### Changed
- Made `AGENTS.md` the explicit default repository instruction source, with `CLAUDE.md` repositioned as Claude-specific guidance.
- Updated release and publishing documentation so Claude marketplace releases check `AGENTS.md`, `CLAUDE.md`, and synced release files together.
- Updated workflow skills to load `AGENTS.md` before `CLAUDE.md` and to evaluate repo-pattern compliance against both instruction files.

### Fixed
- Removed inconsistent workflow wording that previously treated `CLAUDE.md` as the sole source of project rules in planning, research, implementation, finishing, and PR review/fix flows.
- Fixed documentation references so `README.md`, `PUBLISHING.md`, and skill docs consistently mention `AGENTS.md` anywhere `CLAUDE.md` is operationally relevant.

## [1.17.3] - 2026-02-25

### Added
- None.

### Changed
- Updated `skills/feature-documenting/SKILL.md` to require discovery, merge, and cleanup for all workflow `Z*.md` artifacts (including non-standard `ZXX` files), not only Z01-Z05.

### Fixed
- Prevented documentation runs from missing extra workflow artifacts by enforcing full `Z*.md` inclusion in dev logs and cleanup verification.

## [1.17.2] - 2026-02-25

### Added
- None.

### Changed
- Updated `skills/feature-implementing/SKILL.md` Step 4 to explicitly support resuming implementation from an existing `Z99_implementation_status.md`.

### Fixed
- Prevented loss of prior implementation progress by requiring Z99 reconciliation (not recreation) when continuing previously started work.

## [1.17.1] - 2026-02-25

### Added
- None.

### Changed
- Refined Step 5 wording in `skills/feature-implementing/SKILL.md` to require using `superpowers:executing-plans` to execute requested plan tasks, not just invoke/load the skill.

### Fixed
- Updated corresponding checklist and success criteria language in `skills/feature-implementing/SKILL.md` for explicit execution semantics.

## [1.17.0] - 2026-02-24

### Added
- None.

### Changed
- Removed the Plan mode gate from `skills/feature-researching/SKILL.md` so research can run in Default collaboration mode as well.

### Fixed
- Updated `skills/feature-researching/SKILL.md` checklist, red flags, and success criteria to no longer require Plan mode.

## [1.16.1] - 2026-02-24

### Added
- None.

### Changed
- Removed the Plan mode gating requirement from `skills/feature-planning/SKILL.md` so planning can run in default collaboration mode.

### Fixed
- Fixed `feature-planning` step tracking and validation criteria to no longer require or reference Plan mode-only checks.

## [1.16.0] - 2026-02-24

### Added
- Added phased multi-PR planning requirements to `skills/feature-planning/SKILL.md`, including explicit per-phase scope boundaries, dependencies, and verification expectations.
- Added mandatory implementation progress tracking in `skills/feature-implementing/SKILL.md` via `Z99_implementation_status.md`, including per-task status and proof-of-work requirements.
- Added explicit subagent delegation requirement in `skills/feature-implementing/SKILL.md` to invoke `use-sub-agent` when `superpowers:executing-plans` needs subagents.
- Added self-contained research requirements in `skills/feature-researching/SKILL.md` so `Z01_*` includes required source/spec context directly.

### Changed
- Updated `skills/feature-implementing/SKILL.md` completion flow to end on Z99 completion gate (all tasks marked `done` with proof), rather than automatically invoking feature-documenting.

### Fixed
- Prevented mega-PR planning for non-trivial work by enforcing phased, independently reviewable PR plans in `skills/feature-planning/SKILL.md`.
- Prevented implementation completion claims without per-task evidence by making Z99 status + proof mandatory in `skills/feature-implementing/SKILL.md`.
- Prevented research outputs that depend on external docs for core implementation requirements in `skills/feature-researching/SKILL.md`.

## [1.15.0] - 2026-02-23

### Added
- Added explicit Plan mode gate steps to these workflow skills:
  - `skills/feature-documenting/SKILL.md`
  - `skills/feature-finishing/SKILL.md`
  - `skills/feature-planning/SKILL.md`
  - `skills/feature-pr-fixing/SKILL.md`
  - `skills/feature-pr-reviewing/SKILL.md`
  - `skills/feature-researching/SKILL.md`
- Added strict per-item interaction loops for PR review/fix workflows so decisions are collected one finding/comment at a time before execution.

### Changed
- Standardized decision handling to a Codex-first protocol centered on `request_user_input` (with documented compatibility fallback paths where applicable).
- Refined PR review and PR fix execution flow to queue decisions first, execute queued actions in batch, and tighten Z03/Z04 documentation conditions.

### Fixed
- Removed ambiguous guidance that previously encouraged global action prompts or out-of-order execution in interactive review/fix steps.
- Fixed workflow wording inconsistencies around step numbering, completion gates, and push-stage references.

## [1.14.0] - 2026-02-20

### Added
- Added explicit clarification completion gates to keep workflow stages open until clarify files are fully resolved and incorporated:
  - `skills/feature-researching/SKILL.md`
  - `skills/feature-planning/SKILL.md`
- Added README clarification gate documentation for research and planning stages.

### Changed
- Updated research handoff behavior to block planning suggestions while `Z01_CLARIFY_*` is unresolved.
- Updated planning handoff behavior to block implementation suggestions while `Z02_CLARIFY_*` is unresolved.

### Fixed
- Fixed premature workflow advancement when clarify files existed but had unresolved or not-yet-incorporated answers.

## [1.13.1] - 2026-02-17

### Added
- Introduced `CHANGELOG.md` as the canonical versioned release history.

### Changed
- Updated release guidance to require changelog updates before release/tagging in:
  - `AGENTS.md`
  - `CLAUDE.md`
  - `PUBLISHING.md`
  - `README.md`
- Removed legacy `release_notes.md` in favor of changelog-based tracking.

### Fixed
- Removed unsupported `category` frontmatter field from:
  - `skills/feature-documenting/SKILL.md`
  - `skills/feature-implementing/SKILL.md`

## [1.13.0] - 2026-02-17

### Added
- New `use-sub-agent` skill: `skills/use-sub-agent/SKILL.md`.
- New command wrapper: `commands/use-sub-agent.md`.
- Command compatibility symlinks under `prompts/` (including `prompts/use-sub-agent.md`).
- New sync utility script: `scripts/sync_prompts_from_commands.sh`.
- New skill review artifact: `docs/ai/ongoing/Z03_feature-documenting_skill_review.md`.
- `.codex-subagents/` added to `.gitignore`.

### Changed
- Moved root scripts into `scripts/`:
  - `release.sh` -> `scripts/release.sh`
  - `sync_prompts_from_commands.sh` -> `scripts/sync_prompts_from_commands.sh`
- Updated documentation references for prompt compatibility and script locations in `README.md` and `CLAUDE.md`.

### Fixed
- Ensured prompt symlinks can be regenerated from commands with path-safe script logic after moving scripts.
