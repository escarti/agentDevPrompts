# Publishing Guide

## Prerequisites

1. **GitHub Repository**: `git@github.com:escarti/agentDevPrompts.git`
2. **Repository Name**: `agentDevPrompts`

## Repository Structure

This repository is a **Claude Code plugin** containing the **feature-workflow plugin**:

```
agentDevPrompts/
├── .claude-plugin/
│   └── plugin.json        # Plugin manifest (required)
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
# Add all files
git add .
git commit -m "Add plugin files"

# Add remote and push (if not already done)
git remote add origin git@github.com:escarti/agentDevPrompts.git
git push -u origin main
```

### 2. Create Initial Release

```bash
# Tag the release (make sure plugin.json version matches!)
git tag -a v1.0.0 -m "Release v1.0.0: Initial release"
git push origin v1.0.0

# Create GitHub release via gh CLI (optional)
gh release create v1.0.0 \
  --title "v1.0.0 - Initial Release" \
  --notes "Release v1.0.0 with feature-workflow skills"
```

### 3. Test Installation

Users can now install directly from the repository:

```bash
# In Claude Code - Install plugin directly from GitHub
/plugin install https://github.com/escarti/agentDevPrompts.git
```

### 4. Future Updates

When releasing new versions:

1. Update `plugin.json` version number (MUST match git tag!)
2. Commit changes
3. Create new git tag matching the version
4. Push tag to GitHub
5. Users update with: `/plugin update feature-workflow`

## Repository Requirements

Your repository must contain:
- ✅ `.claude-plugin/plugin.json` - Plugin manifest (required)
- ✅ `skills/` directory - Skills directory structure
- ✅ `README.md` - Installation and usage instructions
- ✅ Valid SKILL.md files with proper YAML frontmatter

**Installation method**: Users install directly from the git repository URL. No marketplace.json needed for single plugins.

## Testing Before Publishing

Always test locally first:

```bash
# Manual installation for testing
ln -s ~/Projects/Personal/agentDevPrompts/skills/feature-researching ~/.claude/skills/feature-researching
ln -s ~/Projects/Personal/agentDevPrompts/skills/feature-documenting ~/.claude/skills/feature-documenting

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
- [ ] `plugin.json` version MATCHES git tag
- [ ] README.md has accurate installation instructions
- [ ] No sensitive data in repository
- [ ] .gitignore properly configured
- [ ] Git tag created and pushed

## Quick Release Reference

```bash
# 1. Update version in plugin.json (e.g., "1.2.0")
# 2. Commit and push
git add .claude-plugin/plugin.json
git commit -m "v1.2.0: Description of changes"
git push

# 3. Tag and push (MUST match plugin.json!)
git tag v1.2.0 -m "v1.2.0: Short description"
git push origin v1.2.0
```
