# CLAUDE.md - Development Guidelines

## Project Overview

This repository is a **Claude Code marketplace** containing the **feature-workflow plugin**.

**Repository**: `escarti/agentDevPrompts`
**Plugin**: `feature-workflow` (feature-research, feature-plan, feature-implement, feature-document skills)

## Release Workflow

### CRITICAL: Version Synchronization

**When releasing a new version, you MUST update BOTH:**

1. **Git tag** (e.g., `v1.2.0`)
2. **marketplace.json version fields** (both `metadata.version` and `plugins[0].version`)

**If these don't match, the marketplace distribution will be broken.**

### Release Checklist

Use TodoWrite to track EVERY step:

**Pre-Release:**
- [ ] All skills tested with superpowers:writing-skills (RED-GREEN-REFACTOR)
- [ ] Changes documented in commit message
- [ ] No sensitive data in files

**Version Update (MANDATORY - both files):**
- [ ] Update `.claude-plugin/marketplace.json` → `metadata.version`
- [ ] Update `.claude-plugin/marketplace.json` → `plugins[0].version`
- [ ] Verify both version numbers match the target release version

**Git Operations:**
- [ ] Stage all changes: `git add .`
- [ ] Commit with descriptive message including changelog
- [ ] Push to main: `git push`
- [ ] Create git tag: `git tag v{VERSION} -m "Release message"`
- [ ] Push tag: `git push origin v{VERSION}`

**Verification:**
- [ ] Verify tag on GitHub points to commit with marketplace.json
- [ ] Check marketplace.json in tagged commit has correct version
- [ ] Test installation: `/plugin update feature-workflow`

### Version Numbering

Follow semantic versioning:
- **Major (x.0.0)**: Breaking changes to skill interface or workflow
- **Minor (0.x.0)**: New features, backward compatible (new skills, significant enhancements)
- **Patch (0.0.x)**: Bug fixes, documentation improvements, minor tweaks

**Examples:**
- `1.0.0 → 1.1.0`: Added new skill
- `1.1.0 → 1.2.0`: Compressed skill for token efficiency (significant enhancement)
- `1.2.0 → 1.2.1`: Fixed typo in skill documentation
- `1.2.1 → 2.0.0`: Changed skill file structure (breaking change)

### Release Command Template

```bash
# Example for v1.2.0 release

# 1. Update marketplace.json versions (manually edit file)
# 2. Stage and commit
git add .claude-plugin/marketplace.json skills/
git commit -m "v1.2.0: Description of changes

- Change 1
- Change 2
- Change 3

🤖 Generated with [Claude Code](https://claude.com/claude-code)

Co-Authored-By: Claude <noreply@anthropic.com>"

# 3. Push to main
git push

# 4. Create and push tag
git tag v1.2.0 -m "v1.2.0: Short description"
git push origin v1.2.0
```

### Fixing Mismatched Versions

If you forget to update marketplace.json before tagging:

```bash
# 1. Delete the tag locally and remotely
git tag -d v{VERSION}
git push origin :refs/tags/v{VERSION}

# 2. Update marketplace.json
# Edit .claude-plugin/marketplace.json

# 3. Commit the fix
git add .claude-plugin/marketplace.json
git commit -m "Bump marketplace.json to version {VERSION}"
git push

# 4. Recreate the tag (now points to commit with marketplace.json)
git tag v{VERSION} -m "v{VERSION}: Description"
git push origin v{VERSION}
```

## File Structure

```
agentDevPrompts/
├── .claude-plugin/
│   └── marketplace.json        # VERSION MUST MATCH GIT TAG
├── plugin.json                 # Plugin manifest
├── skills/                     # Skills directory
│   ├── feature-research/
│   │   └── SKILL.md
│   ├── feature-plan/
│   │   └── SKILL.md
│   ├── feature-implement/
│   │   └── SKILL.md
│   └── feature-document/
│       └── SKILL.md
├── CLAUDE.md                   # This file (development guidelines)
├── PUBLISHING.md               # Detailed publishing guide
└── README.md                   # User-facing documentation
```

## marketplace.json Structure

**CRITICAL**: Two version fields must be synchronized:

```json
{
  "name": "feature-workflow",
  "owner": { ... },
  "metadata": {
    "version": "1.2.0"  // ← MUST match git tag
  },
  "plugins": [
    {
      "name": "feature-workflow",
      "version": "1.2.0",  // ← MUST match git tag
      ...
    }
  ]
}
```

**When to update:**
- EVERY time you create a new git tag
- BEFORE creating the tag (not after)
- Update BOTH version fields (metadata.version AND plugins[0].version)

## Filename Sanitization Rules

All skills must follow these standardized rules for creating temporary workflow files:

### Feature Names (Code-Related)
**Used by:** feature-research, feature-plan, feature-implement, feature-finish
**Files:** Z01_*.md, Z02_*.md, Z05_*.md

**Rules:**
- Use snake_case: lowercase with underscores
- Replace spaces and special chars with underscores
- Remove quotes, slashes, colons
- Truncate to 50 characters
- **Example:** "OAuth 2.0 Authentication!" → "oauth_2_0_authentication"

### PR Titles (User-Generated)
**Used by:** feature-prreview, feature-prfix
**Files:** Z03_*.md, Z04_*.md

**Rules:**
- Use kebab-case: lowercase with hyphens
- Replace spaces and special chars with hyphens
- Remove quotes, slashes, colons
- Truncate to 50 characters
- **Example:** "Fix: User Authentication Bug" → "fix-user-authentication-bug"

### Why Two Patterns?

- **snake_case** for feature names: Matches code conventions, flows through Z01→Z02→Z05
- **kebab-case** for PR titles: Matches git branch conventions, handles user-generated text

## Skill Development

### Creating New Skills

Follow superpowers:writing-skills methodology:

**RED Phase:**
- [ ] Create pressure scenarios with subagents
- [ ] Run WITHOUT skill, document failures verbatim
- [ ] Identify rationalizations

**GREEN Phase:**
- [ ] Write minimal skill addressing failures
- [ ] Run WITH skill, verify compliance
- [ ] Word count: aim for <1500 words for frequently-loaded skills

**REFACTOR Phase:**
- [ ] Identify new rationalizations
- [ ] Add explicit counters to rationalization table
- [ ] Re-test until bulletproof

### Editing Existing Skills

**NEVER edit without testing first.**

Same RED-GREEN-REFACTOR cycle:
1. Test current skill (baseline)
2. Make changes
3. Re-test with changes
4. Document new rationalizations discovered
5. Update rationalization table

**Even "minor documentation updates" need testing.**

## Repository Patterns

### Mandatory Patterns

**Release Process:**
- ALWAYS update marketplace.json before tagging
- ALWAYS verify version synchronization
- ALWAYS test skills before releasing
- NEVER skip the release checklist

**Skill Quality:**
- ALWAYS follow TDD for skills (RED-GREEN-REFACTOR)
- ALWAYS include rationalization tables from real testing
- ALWAYS aim for token efficiency (<1500 words for frequent skills)
- NEVER deploy untested skills

**Documentation:**
- CLAUDE.md: Development guidelines (this file)
- PUBLISHING.md: Detailed publishing process
- README.md: User-facing installation and usage
- Keep CLAUDE.md focused on patterns that agents MUST follow

## Forbidden Patterns

**DO NOT:**
- Tag a release without updating marketplace.json first
- Update only one version field in marketplace.json (must update both)
- Edit skills without running RED-GREEN-REFACTOR testing
- Create hypothetical rationalization tables (must come from real agent testing)
- Skip release checklist steps
- Assume "minor changes" don't need testing

## Common Rationalizations

| Excuse | Reality |
|--------|---------|
| "Just a version bump, skip checklist" | Version sync is CRITICAL. Follow checklist. |
| "Marketplace.json can be updated later" | Tag will point to wrong commit. Update BEFORE tagging. |
| "Minor doc fix, no need to test" | Untested changes break in production. ALWAYS test. |
| "I'll remember the version sync next time" | You'll forget under pressure. Use TodoWrite checklist. |
| "Users can wait for v1.2.1 to fix version" | Broken releases damage trust. Get it right first time. |

## Red Flags - STOP and Fix

When releasing a version:
- Did NOT update marketplace.json before creating tag
- Updated only one version field in marketplace.json
- Skipped testing skills before release
- No TodoWrite checklist for release steps
- Git tag version doesn't match marketplace.json versions

**All of these mean:** Stop, fix synchronization, recreate tag correctly.

## Testing Before Release

**Local Testing:**
```bash
# Use symlinks for development
ln -s ~/Projects/Personal/prompts/skills/feature-research ~/.claude/skills/feature-research
ln -s ~/Projects/Personal/prompts/skills/feature-plan ~/.claude/skills/feature-plan
ln -s ~/Projects/Personal/prompts/skills/feature-implement ~/.claude/skills/feature-implement
ln -s ~/Projects/Personal/prompts/skills/feature-document ~/.claude/skills/feature-document

# Test skills in Claude Code
# Verify changes work as expected
```

**Subagent Testing (for skill changes):**
- Use superpowers:testing-skills-with-subagents
- Run pressure scenarios (time pressure, authority pressure, sunk cost)
- Document rationalizations verbatim
- Update rationalization tables with real evidence

## Automation Wishlist

**Future improvements:**
- Pre-commit hook to verify marketplace.json version matches current branch/tag
- CI check that marketplace.json versions are synchronized
- Automated testing of skills with subagents before release

Until automated, follow the release checklist religiously.

## Summary

**The Two Critical Rules:**

1. **Version Synchronization**: Git tag MUST match marketplace.json (both fields)
2. **Testing Before Release**: Skills MUST be tested with RED-GREEN-REFACTOR

**When releasing:**
- Use TodoWrite for release checklist
- Update marketplace.json BEFORE creating tag
- Verify synchronization before pushing
- Test skills before committing

**The checklist exists because humans (and agents) forget under pressure.**
