# Feature Workflow - Claude Code Skills

Research-driven feature development workflow for Claude Code, with superpowers integration for planning, implementation, finishing, and PR handling.

## Included Skills

Core workflow:
- `feature-researching` (requires superpowers)
- `feature-planning` (requires superpowers)
- `feature-implementing` (requires superpowers)
- `feature-documenting` (standalone)

Quality and PR workflow:
- `feature-finishing` (requires superpowers)
- `feature-pr-reviewing` (requires superpowers)
- `feature-pr-fixing` (requires superpowers)

Bootstrap helper:
- `load-superpowers` (loads required superpowers skills before feature-* skills that depend on them)

Utility:
- `use-sub-agent` (orchestrates headless `codex --yolo exec` subagents with safe parallel/log patterns)

## Dependencies

Install [superpowers](https://github.com/obra/superpowers) from the marketplace/plugin system for:
- `feature-researching`
- `feature-planning`
- `feature-implementing`
- `feature-finishing`
- `feature-pr-reviewing`
- `feature-pr-fixing`

`feature-documenting` is standalone.

```bash
# In Claude Code
/plugin marketplace add obra/superpowers
/plugin install superpowers@obra/superpowers
```

`load-superpowers` is a compatibility shim for these workflow skills. It now assumes `superpowers:*` skills are provided by the marketplace install and no longer bootstraps from a local `~/.codex/superpowers` checkout.

Run `load-superpowers` before:
- `feature-researching`
- `feature-planning`
- `feature-implementing`
- `feature-finishing`
- `feature-pr-reviewing`
- `feature-pr-fixing`

## Installation

### Option 1: Claude Code Marketplace (Recommended)

```bash
# In Claude Code
/plugin marketplace add escarti/agentDevPrompts
/plugin install feature-workflow@agentDevPrompts
```

Verify:
```bash
/help
```

Expected commands:
- `/feature-research`
- `/feature-plan`
- `/feature-implement`
- `/feature-document`
- `/feature-finish`
- `/feature-prreview`
- `/feature-prfix`

### Option 2: Manual Skill Symlinks (Development)

```bash
git clone git@github.com:escarti/agentDevPrompts.git ~/Projects/Personal/agentDevPrompts

ln -s ~/Projects/Personal/agentDevPrompts/skills/feature-researching ~/.claude/skills/feature-researching
ln -s ~/Projects/Personal/agentDevPrompts/skills/feature-planning ~/.claude/skills/feature-planning
ln -s ~/Projects/Personal/agentDevPrompts/skills/feature-implementing ~/.claude/skills/feature-implementing
ln -s ~/Projects/Personal/agentDevPrompts/skills/feature-documenting ~/.claude/skills/feature-documenting
ln -s ~/Projects/Personal/agentDevPrompts/skills/feature-finishing ~/.claude/skills/feature-finishing
ln -s ~/Projects/Personal/agentDevPrompts/skills/feature-pr-reviewing ~/.claude/skills/feature-pr-reviewing
ln -s ~/Projects/Personal/agentDevPrompts/skills/feature-pr-fixing ~/.claude/skills/feature-pr-fixing
ln -s ~/Projects/Personal/agentDevPrompts/skills/load-superpowers ~/.claude/skills/load-superpowers
ln -s ~/Projects/Personal/agentDevPrompts/skills/use-sub-agent ~/.claude/skills/use-sub-agent
```

These symlinks install only `feature-workflow`. Superpowers remains a separate marketplace dependency; do not point this setup at a local `~/.codex/superpowers` clone.

### Option 3: Codex Skill Installer

In Codex, paste and run this command to install all workflow skills from this repository:

```text
Use the skill-installer skill to install these skills https://github.com/escarti/agentDevPrompts/tree/main/skills/*
```

Restart Codex to pick up new skills.

## Migrating Off Legacy Local Superpowers

Older setups may still have a local Superpowers checkout at `~/.codex/superpowers`. This repository no longer uses that path.

After confirming the marketplace-installed `superpowers:*` skills resolve correctly through `load-superpowers`, remove only the legacy Superpowers assets:

```bash
rm -rf ~/.codex/superpowers
find ~/.codex/skills -maxdepth 1 \( -type l -o -type d \) | rg '/superpowers$'
```

Keep the `feature-workflow` entries in `~/.codex/skills` such as `feature-researching`, `feature-planning`, `feature-implementing`, `load-superpowers`, and `use-sub-agent`. Those are separate from the legacy Superpowers checkout and should continue to point at this repository.

## Workflow

1. Start with `feature-workflow:feature-researching`
2. Plan with `feature-workflow:feature-planning`
3. Implement with `feature-workflow:feature-implementing`
4. Finish with `feature-workflow:feature-finishing`
5. Document with `feature-workflow:feature-documenting`

### Quick Guide (Intended Use)

| Stage | Use this | Goal | Input | Output |
| --- | --- | --- | --- | --- |
| 1. Single entry point: idea triage + repo-grounded research | `feature-workflow:feature-researching` | Accept a rough idea, partial spec, or detailed request; refine intent when needed; then ground the feature in the repo and surface blind spots | Rough idea, partial spec, or detailed request | `Z01_*_research.md` (final) and optional `Z01_CLARIFY_*_research.md` |
| 2. Ambiguity-free planning | `feature-workflow:feature-planning` (wrapper of superpowers `writing-plans`) | Convert clear spec + research into an actionable implementation plan, then optionally publish the approved plan into GitHub issues or a Jira epic plus tasks | Finalized spec + resolved clarify answers + Z01 research | `Z02_*_plan.md` (final), optional temporary `Z02_CLARIFY_*_plan.md`, and optional approved tracker items |
| 3. Execution | `feature-workflow:feature-implementing` (wrapper of superpowers execution workflow) | Execute from the canonical Z02 plan or from an approved published tracker graph with the same task/dependency detail | `Z02_*_plan.md` or approved tracker entrypoint | Implemented code + verification + handoff to documentation |
| 4. Final quality check | `feature-workflow:feature-finishing` | Run a fresh-context quality pass before documenting/merge prep | Implemented code + plan/research context | Findings summary and/or fixes, plus finish artifact (`Z05_*`) when applicable |
| 5. Documentation and cleanup | `feature-workflow:feature-documenting` | Consolidate artifacts and clean temporary workflow files | Z-files and implementation results | Dev log + PR-ready summary |

`feature-researching` may invoke `superpowers:brainstorming` internally for low-definition inputs or for medium-definition requests that still have product-level ambiguity after 1-3 targeted clarification questions. Brainstorming is an internal refinement step in this workflow, not a separate user-facing prerequisite for ordinary feature work.

Use the full flow for large features where discovery, planning, and execution need strict structure.

For small features or bug fixes, you can start in the middle:
- Skip directly to planning or implementation when you already have a clear input.
- A small bug can be handled with a short markdown brief (issue, desired end state, and test approach) and then passed directly to implementation.

Common temporary artifacts:
- `docs/ai/ongoing/Z01_{feature}_research.md`
- `docs/ai/ongoing/Z01_CLARIFY_{feature}_research.md`
- `docs/ai/ongoing/Z02_{feature}_plan.md`
- `docs/ai/ongoing/Z02_CLARIFY_{feature}_plan.md` (only when planning discovers new blockers)

Optional tracker publication after planning:
- `feature-planning` can preview and publish the approved `Z02_*_plan.md` into:
  - GitHub: one parent roadmap issue plus one child issue per Z02 task
  - Jira: one epic plus one task per Z02 task
- Publication is never automatic. The workflow previews destination, tasks, and dependencies first and waits for explicit approval before mutation.
- `Z02_*_plan.md` remains the canonical local planning artifact even when tracker items are published. Tracker items are a projection of the approved Z02, not a separate planning flow.
- Published tracker items must be self-contained. They must not rely on links to `Z0X` workflow files, local file paths, or other transient local artifacts for required implementation context.

Clarification gates:
- Research is not complete while `Z01_CLARIFY_*_research.md` has unresolved questions.
- Planning is not complete while `Z02_CLARIFY_*_plan.md` has unresolved questions.
- The workflow must stay in the current stage and wait; do not jump to the next stage until clarify items are incorporated and clarify file is removed (or emptied).

Additional temporary artifacts may be created in PR/finish flows:
- `Z03_*`, `Z04_*`, `Z05_*` in the same ongoing directory

## Prompt Install Scripts (Codex and Copilot)

This repository also includes scripts for legacy prompt files (`A01_*`, `A02_*`, `A03_*`):
- `install_codex.sh`: copies prompts to `~/.codex/prompts`
- `install_copilot_prompts.sh`: installs prompts to VS Code User prompts directory as `*.prompt.md`
- `create_symlink_prompt.sh`: symlinks prompts into `.prompts/` in the current repo and updates `.gitignore`
- `install_symlink.sh`: installs `add_prompts` command in `~/.local/bin` pointing to `create_symlink_prompt.sh`

Command/prompt compatibility:
- `prompts/*.md` are symlinks to `commands/*.md`
- Run `./scripts/sync_prompts_from_commands.sh` after adding/removing command files

## Repository Structure

```text
agentDevPrompts/
├── .claude-plugin/
│   ├── marketplace.json
│   └── plugin.json
├── commands/
├── prompts/   (symlinks to commands for Codex prompt compatibility)
├── scripts/
├── skills/
│   ├── feature-researching/
│   ├── feature-planning/
│   ├── feature-implementing/
│   ├── feature-documenting/
│   ├── feature-finishing/
│   ├── feature-pr-reviewing/
│   ├── feature-pr-fixing/
│   ├── load-superpowers/
│   └── use-sub-agent/
├── docs/
├── AGENTS.md
├── CLAUDE.md
├── scripts/sync_prompts_from_commands.sh
├── scripts/release.sh
├── PUBLISHING.md
└── README.md
```

## Development Notes

- `feature-planning` wraps superpowers `writing-plans`.
- `feature-implementing` wraps superpowers `executing-plans`.
- `feature-finishing` and `feature-pr-fixing` leverage superpowers debugging workflows.
- Keep version fields synchronized before release (see `AGENTS.md`, `CLAUDE.md`, and `PUBLISHING.md`).

## Attribution

This plugin builds on [superpowers](https://github.com/obra/superpowers) by [Jesse Vincent](https://github.com/obra). The feature-workflow skills add structured research/clarification artifacts and workflow-specific orchestration around those core skills.

## License

MIT License - see [LICENSE](LICENSE).

## Changelog

See `CHANGELOG.md` for version-by-version release history.
