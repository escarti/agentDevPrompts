# Changelog

All notable changes to this project are documented in this file.

The format is based on Keep a Changelog and this project follows semantic versioning for git tags.

## [Unreleased]

### Added
- None yet.

### Changed
- None yet.

### Fixed
- None yet.

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
