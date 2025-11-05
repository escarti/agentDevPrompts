# Feature Workflow - Claude Code Skills

Research-driven feature development workflow for Claude Code. Produces directive specifications with structured clarifications, integrated with superpowers workflow.

## Skills Included

- **feature-research** - Systematic feature research producing directive specifications with zero ambiguity _(standalone)_
- **feature-plan** - Create implementation plans from research with automatic context loading _(requires superpowers)_
- **feature-implement** - Execute plans with batch processing and code review checkpoints _(requires superpowers)_
- **feature-document** - Post-implementation consolidation, cleanup, and PR generation _(standalone)_

## Dependencies

**feature-plan** and **feature-implement** are wrapper skills that require the [superpowers plugin](https://github.com/obra/superpowers) by Jesse Vincent.

These skills extend superpowers' battle-tested `writing-plans` and `executing-plans` workflows by automatically loading context from the feature-workflow research phase (Z01/Z02 files).

**feature-research** and **feature-document** are fully standalone and work independently.

## Installation

### Prerequisites

**Install superpowers** (required for feature-plan and feature-implement):

```bash
# In Claude Code
/plugin marketplace add obra/superpowers
/plugin install superpowers@obra/superpowers
```

### Option 1: Via Plugin Marketplace (Recommended)

This repository is a Claude Code marketplace containing the feature-workflow plugin.

```bash
# In Claude Code
# Step 1: Add the marketplace
/plugin marketplace add escarti/agentDevPrompts

# Step 2: Install the plugin from the marketplace
/plugin install feature-workflow@feature-workflow
```

Verify installation:
```bash
/help

# Should see:
# /feature-research - Research-driven feature specification
# /feature-plan - Create implementation plan
# /feature-implement - Execute plan with review checkpoints
# /feature-document - Post-implementation documentation
```

### Option 2: Manual Installation (Development)

Clone this repository and symlink to Claude Code:

```bash
# Clone the repository
git clone git@github.com:escarti/agentDevPrompts.git ~/Projects/Personal/agentDevPrompts

# Create symlinks
ln -s ~/Projects/Personal/agentDevPrompts/skills/feature-research ~/.claude/skills/feature-research
ln -s ~/Projects/Personal/agentDevPrompts/skills/feature-plan ~/.claude/skills/feature-plan
ln -s ~/Projects/Personal/agentDevPrompts/skills/feature-implement ~/.claude/skills/feature-implement
ln -s ~/Projects/Personal/agentDevPrompts/skills/feature-document ~/.claude/skills/feature-document
```

**Single Source of Truth**: Edit skills in the cloned repo, changes are immediately available via symlinks.

## Repository Structure

```
agentDevPrompts/
├── .claude-plugin/
│   └── marketplace.json           # Marketplace catalog (enables marketplace installation)
├── plugin.json                    # Plugin manifest
├── skills/                        # Claude Code skills
│   ├── feature-research/
│   │   └── SKILL.md
│   ├── feature-plan/
│   │   └── SKILL.md
│   ├── feature-implement/
│   │   └── SKILL.md
│   └── feature-document/
│       └── SKILL.md
├── A01_research_agent.md          # Original research agent prompt
├── A02_plan_agent.md              # Original planning agent prompt
├── A03_implement_agent.md         # Original implementation agent prompt
└── README.md                      # This file
```

**Note**: The `.claude-plugin/marketplace.json` file makes this repository installable as a marketplace. It contains a catalog that references the feature-workflow plugin in the same repository.

## Workflow

### New Feature Development

1. **Research Phase** - Use `feature-workflow:feature-research` skill _(standalone)_
   - Produces: `docs/ai/ongoing/Z01_{feature}_research.md`
   - Produces: `docs/ai/ongoing/Z01_CLARIFY_{feature}_research.md`
   - User answers clarification questions

2. **Planning Phase** - Use `feature-workflow:feature-plan` skill _(requires superpowers)_
   - Input: `docs/ai/ongoing/Z01_{feature}_research.md`
   - Wraps `superpowers:writing-plans` with automatic context loading
   - Produces: `docs/ai/ongoing/Z02_{feature}_plan.md`

3. **Implementation Phase** - Use `feature-workflow:feature-implement` skill _(requires superpowers)_
   - Input: `docs/ai/ongoing/Z02_{feature}_plan.md`
   - Wraps `superpowers:executing-plans` with automatic context loading
   - Implements the plan in batches with code review checkpoints

4. **Documentation Phase** - Use `feature-workflow:feature-document` skill _(standalone, auto-invoked)_
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
- Complete workflow: `feature-workflow:feature-research` → `feature-workflow:feature-plan` → `feature-workflow:feature-implement` → `feature-workflow:feature-document`
- Wrapper skills (`feature-workflow:feature-plan`, `feature-workflow:feature-implement`) extend superpowers' battle-tested workflows with Z0* context loading

**Note**: feature-plan wraps `superpowers:writing-plans` and feature-implement wraps `superpowers:executing-plans`. These core skills from superpowers handle the actual planning and execution logic.

## Contributing

### For Plugin Users

To contribute improvements:
1. Fork this repository
2. Make changes to skills in `skills/` directory
3. Test locally using manual installation method
4. Submit a pull request

### For Plugin Maintainers

To release a new version:
1. Update `plugin.json` version number
2. Test changes with manual installation
3. Commit and push to main branch
4. Create a GitHub release with version tag
5. Users will get updates via `/plugin update feature-workflow`

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

**feature-plan** and **feature-implement** are thin wrappers around superpowers' `writing-plans` and `executing-plans` skills. These core workflows were designed and battle-tested by Jesse and the superpowers community. feature-workflow extends them by:
- Automatically loading research context (Z01/Z02 files)
- Integrating with the feature-workflow's research → plan → implement → document pipeline
- Maintaining consistency with feature-workflow file naming conventions

The real credit for the planning and execution methodology goes to superpowers.

**feature-research** and **feature-document** are original contributions to enable research-driven specification and post-implementation consolidation.

## License

MIT License - see [LICENSE](LICENSE) for details.
