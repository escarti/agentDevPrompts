# Feature Workflow - Claude Code Skills

Research-driven feature development workflow for Claude Code. Produces directive specifications with structured clarifications, integrated with superpowers workflow.

## Skills Included

**Core Workflow:**
- **feature-researching** - Systematic feature research producing directive specifications _(standalone)_
- **feature-planning** - Create implementation plans from research with context loading _(requires superpowers)_
- **feature-implementing** - Execute plans with batch processing and review checkpoints _(requires superpowers)_
- **feature-documenting** - Post-implementation consolidation, cleanup, and PR generation _(standalone)_

**Quality & PR Workflows:**
- **feature-finishing** - Final quality check with fresh-context analysis before merge _(requires superpowers)_
- **feature-pr-reviewing** - Review PR changes with research-driven analysis _(requires superpowers)_
- **feature-pr-fixing** - Address PR review comments with validity assessment _(requires superpowers)_

## Dependencies

**feature-planning** and **feature-implementing** are wrapper skills that require the [superpowers plugin](https://github.com/obra/superpowers) by Jesse Vincent.

These skills extend superpowers' battle-tested `writing-plans` and `executing-plans` workflows by automatically loading context from the feature-workflow research phase (Z01/Z02 files).

**feature-researching** and **feature-documenting** are fully standalone and work independently.

## Installation

### Prerequisites

**Install superpowers** (required for feature-planning and feature-implementing):

```bash
# In Claude Code
/plugin marketplace add obra/superpowers
/plugin install superpowers@obra/superpowers
```

### Install feature-workflow Plugin

```bash
# In Claude Code - Install directly from GitHub
/plugin install https://github.com/escarti/agentDevPrompts.git
```

Verify installation:
```bash
/help

# Should see all 7 commands:
# /feature-research - Research codebase using structured workflow
# /feature-plan - Create implementation plan using structured workflow
# /feature-implement - Execute implementation plan using structured workflow
# /feature-document - Consolidate artifacts into dev log using structured workflow
# /feature-finish - Perform final quality check using structured workflow
# /feature-prreview - Review pull request changes using structured workflow
# /feature-prfix - Address PR review comments using structured workflow
```

### Manual Installation (Development)

Clone this repository and symlink to Claude Code:

```bash
# Clone the repository
git clone git@github.com:escarti/agentDevPrompts.git ~/Projects/Personal/agentDevPrompts

# Create symlinks for all skills
ln -s ~/Projects/Personal/agentDevPrompts/skills/feature-researching ~/.claude/skills/feature-researching
ln -s ~/Projects/Personal/agentDevPrompts/skills/feature-planning ~/.claude/skills/feature-planning
ln -s ~/Projects/Personal/agentDevPrompts/skills/feature-implementing ~/.claude/skills/feature-implementing
ln -s ~/Projects/Personal/agentDevPrompts/skills/feature-documenting ~/.claude/skills/feature-documenting
ln -s ~/Projects/Personal/agentDevPrompts/skills/feature-finishing ~/.claude/skills/feature-finishing
ln -s ~/Projects/Personal/agentDevPrompts/skills/feature-pr-reviewing ~/.claude/skills/feature-pr-reviewing
ln -s ~/Projects/Personal/agentDevPrompts/skills/feature-pr-fixing ~/.claude/skills/feature-pr-fixing
```

**Single Source of Truth**: Edit skills in the cloned repo, changes are immediately available via symlinks.

## Repository Structure

```
agentDevPrompts/
├── .claude-plugin/
│   └── plugin.json               # Plugin manifest
├── commands/                      # Slash commands
│   ├── feature-research.md
│   ├── feature-plan.md
│   ├── feature-implement.md
│   ├── feature-document.md
│   ├── feature-finish.md
│   ├── feature-prreview.md
│   └── feature-prfix.md
├── skills/                        # Skills
│   ├── feature-researching/
│   ├── feature-planning/
│   ├── feature-implementing/
│   ├── feature-documenting/
│   ├── feature-finishing/
│   ├── feature-pr-reviewing/
│   └── feature-pr-fixing/
├── CLAUDE.md                      # Development guidelines
├── PUBLISHING.md                  # Release workflow
└── README.md                      # This file
```

## Workflow

### New Feature Development

1. **Research Phase** - Use `feature-workflow:feature-researching` skill _(standalone)_
   - Produces: `docs/ai/ongoing/Z01_{feature}_research.md`
   - Produces: `docs/ai/ongoing/Z01_CLARIFY_{feature}_research.md`
   - User answers clarification questions

2. **Planning Phase** - Use `feature-workflow:feature-planning` skill _(requires superpowers)_
   - Input: `docs/ai/ongoing/Z01_{feature}_research.md`
   - Wraps `superpowers:writing-plans` with automatic context loading
   - Produces: `docs/ai/ongoing/Z02_{feature}_plan.md`

3. **Implementation Phase** - Use `feature-workflow:feature-implementing` skill _(requires superpowers)_
   - Input: `docs/ai/ongoing/Z02_{feature}_plan.md`
   - Wraps `superpowers:executing-plans` with automatic context loading
   - Implements the plan in batches with code review checkpoints

4. **Documentation Phase** - Use `feature-workflow:feature-documenting` skill _(standalone, auto-invoked)_
   - Consolidates Z01 + Z02 + implementation summary
   - Produces: `docs/ai/dev_logs/{YYYYMMDD}_{feature}_dev_log.md`
   - Cleans up `docs/ai/ongoing/Z01*` and `Z02*` files
   - Generates PR description

## File Locations

**Research & Planning** (temporary):
- `docs/ai/ongoing/Z01_{feature}_research.md`
- `docs/ai/ongoing/Z01_CLARIFY_{feature}_research.md`
- `docs/ai/ongoing/Z02_{feature}_plan.md`

**Development Logs** (permanent):
- `docs/ai/dev_logs/{YYYYMMDD}_{feature}_dev_log.md`

## Skills vs Original Prompts

**Original Prompts (A01, A02, A03)**:
- Designed for separate agent instances
- Multi-agent workflow (research → plan → implement)
- Use when working with multiple specialized agents

**Claude Code Skills**:
- Designed for single Claude Code session
- Integrated with [superpowers](https://github.com/obra/superpowers) workflow (by Jesse Vincent)
- Complete workflow: `feature-workflow:feature-researching` → `feature-workflow:feature-planning` → `feature-workflow:feature-implementing` → `feature-workflow:feature-documenting`
- Wrapper skills (`feature-workflow:feature-planning`, `feature-workflow:feature-implementing`) extend superpowers' battle-tested workflows with Z0* context loading

**Note**: feature-planning wraps `superpowers:writing-plans` and feature-implementing wraps `superpowers:executing-plans`. These core skills from superpowers handle the actual planning and execution logic.

## Contributing

### For Plugin Users

To contribute improvements:
1. Fork this repository
2. Make changes to skills in `skills/` directory
3. Test locally using manual installation method
4. Submit a pull request

### For Plugin Maintainers

To release a new version:
1. Update `plugin.json` version number (MUST match git tag!)
2. Test changes with manual installation
3. Commit and push to main branch
4. Create git tag matching the version: `git tag v1.2.0 -m "v1.2.0: Description"`
5. Push tag: `git push origin v1.2.0`
6. Users will get updates via `/plugin update feature-workflow`

## Development

### Testing Changes

Use manual installation (symlinks) for development:
```bash
# Your changes in the repo are immediately available via symlinks
# Test by using skills in Claude Code
```

### Adding New Skills

1. Create `skills/new-skill/SKILL.md`
2. Add to `plugin.json`:
   ```json
   {
     "skills": {
       "new-skill": "skills/new-skill"
     }
   }
   ```
3. Follow TDD approach from `superpowers:writing-skills`
4. Test before committing

## Attribution

This plugin builds upon the excellent [superpowers](https://github.com/obra/superpowers) project by [Jesse Vincent](https://github.com/obra).

**feature-planning** and **feature-implementing** are thin wrappers around superpowers' `writing-plans` and `executing-plans` skills. These core workflows were designed and battle-tested by Jesse and the superpowers community. feature-workflow extends them by:
- Automatically loading research context (Z01/Z02 files)
- Integrating with the feature-workflow's research → plan → implement → document pipeline
- Maintaining consistency with feature-workflow file naming conventions

The real credit for the planning and execution methodology goes to superpowers.

**feature-researching** and **feature-documenting** are original contributions to enable research-driven specification and post-implementation consolidation.

## License

MIT License - see [LICENSE](LICENSE) for details.
