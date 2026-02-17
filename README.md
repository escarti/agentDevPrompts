# Feature Workflow - Claude Code Skills

Research-driven feature development workflow for Claude Code, with superpowers integration for planning, implementation, finishing, and PR handling.

## Included Skills

Core workflow:
- `feature-researching` (standalone)
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

Install [superpowers](https://github.com/obra/superpowers) for:
- `feature-planning`
- `feature-implementing`
- `feature-finishing`
- `feature-pr-reviewing`
- `feature-pr-fixing`

`feature-researching` and `feature-documenting` are standalone.

```bash
# In Claude Code
/plugin marketplace add obra/superpowers
/plugin install superpowers@obra/superpowers
```

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

### Option 3: Codex Skill Installer

In Codex, paste and run this command to install all workflow skills from this repository:

```text
Use the skill-installer skill to install these skills https://github.com/escarti/agentDevPrompts/tree/main/skills/*
```

Restart Codex to pick up new skills.

## Workflow

1. Research with `feature-workflow:feature-researching`
2. Plan with `feature-workflow:feature-planning`
3. Implement with `feature-workflow:feature-implementing`
4. Finish with `feature-workflow:feature-finishing`
5. Document with `feature-workflow:feature-documenting`

### Quick Guide (Intended Use)

| Stage | Use this | Goal | Input | Output |
| --- | --- | --- | --- | --- |
| 0. Idea to spec | `superpowers:brainstorming` | Turn a rough idea into a detailed spec | Problem statement, constraints, success criteria | Detailed specification |
| 1. Repository-grounded research | `feature-workflow:feature-researching` | Check how the spec fits the repo and surface blind spots | Detailed specification | `Z01_*_research.md` and `Z01_CLARIFY_*_research.md` |
| 2. Ambiguity-free planning | `feature-workflow:feature-planning` (wrapper of superpowers `writing-plans`) | Convert clear spec + research into an actionable implementation plan | Finalized spec + resolved clarify answers + Z01 research | `Z02_*_plan.md` |
| 3. Execution | `feature-workflow:feature-implementing` (wrapper of superpowers execution workflow) | Execute the plan in batches with review checkpoints | `Z02_*_plan.md` | Implemented code + verification + handoff to documentation |
| 4. Final quality check | `feature-workflow:feature-finishing` | Run a fresh-context quality pass before documenting/merge prep | Implemented code + plan/research context | Findings summary and/or fixes, plus finish artifact (`Z05_*`) when applicable |
| 5. Documentation and cleanup | `feature-workflow:feature-documenting` | Consolidate artifacts and clean temporary workflow files | Z-files and implementation results | Dev log + PR-ready summary |

Use the full flow for large features where discovery, planning, and execution need strict structure.

For small features or bug fixes, you can start in the middle:
- Skip directly to planning or implementation when you already have a clear input.
- A small bug can be handled with a short markdown brief (issue, desired end state, and test approach) and then passed directly to implementation.

Common temporary artifacts:
- `docs/ai/ongoing/Z01_{feature}_research.md`
- `docs/ai/ongoing/Z01_CLARIFY_{feature}_research.md`
- `docs/ai/ongoing/Z02_{feature}_plan.md`

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
- Keep version fields synchronized before release (see `CLAUDE.md` and `PUBLISHING.md`).

## Attribution

This plugin builds on [superpowers](https://github.com/obra/superpowers) by [Jesse Vincent](https://github.com/obra). The feature-workflow skills add structured research/clarification artifacts and workflow-specific orchestration around those core skills.

## License

MIT License - see [LICENSE](LICENSE).
