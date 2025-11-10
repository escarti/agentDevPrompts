# Publishing Guide

## Prerequisites

1. **GitHub Repository**: `git@github.com:escarti/agentDevPrompts.git`
2. **Repository Name**: `agentDevPrompts` (matches the marketplace identifier)

## Repository Structure

This repository is a **marketplace** that contains the **feature-workflow plugin**:

```
agentDevPrompts/
├── .claude-plugin/
│   ├── marketplace.json    # Marketplace catalog (required)
│   └── plugin.json        # Plugin manifest
├── commands/              # Slash commands
├── skills/                # Plugin skills (gerund form)
│   ├── feature-researching/
│   ├── feature-planning/
│   ├── feature-implementing/
│   ├── feature-documenting/
│   ├── feature-finishing/
│   ├── feature-pr-reviewing/
│   └── feature-pr-fixing/
└── ...
```

## Publishing Steps

### 1. Push to GitHub

```bash
# Add all files including marketplace.json
git add .
git commit -m "Add marketplace.json and plugin files"

# Add remote and push (if not already done)
git remote add origin git@github.com:escarti/agentDevPrompts.git
git push -u origin main
```

### 2. Create Initial Release

```bash
# Tag the release
git tag -a v1.0.0 -m "Release v1.0.0: Initial release"
git push origin v1.0.0

# Create GitHub release via gh CLI
gh release create v1.0.0 \
  --title "v1.0.0 - Initial Release" \
  --notes "Release v{VERSION} with feature-workflow skills"
```

### 3. Test Installation

Users can now install via:

```bash
# In Claude Code - Add the marketplace
/plugin marketplace add escarti/agentDevPrompts

# Install the plugin from the marketplace
/plugin install feature-workflow@agentDevPrompts
```

### 4. Future Updates

When releasing new versions:

1. Update `plugin.json` version number
2. Commit changes
3. Create new git tag and GitHub release
4. Users update with: `/plugin update feature-workflow`

## Repository Requirements

Your repository must contain:
- ✅ `.claude-plugin/marketplace.json` - Marketplace catalog (required for `/plugin marketplace add`)
- ✅ `plugin.json` - Plugin manifest
- ✅ `skills/` directory - Skills directory structure
- ✅ `README.md` - Installation and usage instructions
- ✅ Valid SKILL.md files with proper YAML frontmatter

**Key distinction**: The `.claude-plugin/marketplace.json` file makes this a marketplace that can be added via `/plugin marketplace add`. It references the plugin in the same repository.

## Testing Before Publishing

Always test locally first:

```bash
# Manual installation for testing
ln -s ~/Projects/Personal/agentDevPrompts/skills/feature-researching ~/.claude/skills/feature-researching
ln -s ~/Projects/Personal/agentDevPrompts/skills/development-logging ~/.claude/skills/development-logging

# Verify skills work in Claude Code
# Then remove symlinks and test plugin installation
```

## Version Numbering

Follow semantic versioning:
- **Major** (1.0.0): Breaking changes
- **Minor** (0.1.0): New features, backward compatible
- **Patch** (0.0.1): Bug fixes

## Distribution Checklist

Before publishing:
- [ ] All skills tested and working
- [ ] `plugin.json` has correct version
- [ ] README.md has accurate installation instructions
- [ ] No sensitive data in repository
- [ ] .gitignore properly configured
- [ ] Git tags match plugin.json version
- [ ] GitHub release created
