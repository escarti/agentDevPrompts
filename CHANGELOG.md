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
