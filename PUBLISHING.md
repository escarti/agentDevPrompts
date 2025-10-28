# Publishing Guide

## Prerequisites

1. **GitHub Repository**: `git@github.com:escarti/agentDevPrompts.git`
2. **Repository Name**: `agentDevPrompts` (matches the marketplace identifier)

## Publishing Steps

### 1. Push to GitHub

```bash
# Initialize git (if not already done)
git init
git add .
git commit -m "Initial commit: feature-workflow plugin"

# Add remote and push
git remote add origin git@github.com:escarti/agentDevPrompts.git
git push -u origin main
```

### 2. Create Initial Release

```bash
# Tag the release
git tag -a v1.0.0 -m "Release v1.0.0: Initial release"
git push origin v1.0.0

# Create GitHub release via web UI or gh CLI
gh release create v1.0.0 \
  --title "v1.0.0 - Initial Release" \
  --notes "Initial release with feature-research and development-logging skills"
```

### 3. Test Installation

Users can now install via:

```bash
# In Claude Code
/plugin marketplace add escarti/agentDevPrompts
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
- ✅ `plugin.json` - Plugin manifest
- ✅ `skills/` directory - Skills directory structure
- ✅ `README.md` - Installation and usage instructions
- ✅ Valid SKILL.md files with proper YAML frontmatter

## Testing Before Publishing

Always test locally first:

```bash
# Manual installation for testing
ln -s ~/Projects/Personal/agentDevPrompts/skills/feature-research ~/.claude/skills/feature-research
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
