# CLAUDE.md - Development Guidelines

## Project Overview

This repository is a **Claude Code marketplace** containing the **feature-workflow plugin**.

**Repository**: `escarti/agentDevPrompts`
**Plugin**: `feature-workflow` (feature-researching, feature-planning, feature-implementing, feature-documenting, feature-finishing, feature-pr-reviewing, feature-pr-fixing skills)

## Release Workflow

### CRITICAL: Version Synchronization

**When releasing a new version, you MUST update ALL THREE:**

1. **Git tag** (e.g., `v1.2.0`)
2. **plugin.json version field** (`version`)
3. **marketplace.json version fields** (both `metadata.version` and `plugins[0].version`)

**If these don't match, the marketplace distribution will be broken.**

**All four version locations must be synchronized:**
- Git tag: `v1.2.0`
- `.claude-plugin/plugin.json` → `version: "1.2.0"`
- `.claude-plugin/marketplace.json` → `metadata.version: "1.2.0"`
- `.claude-plugin/marketplace.json` → `plugins[0].version: "1.2.0"`

### Release Checklist

Use TodoWrite to track EVERY step:

**Pre-Release:**
- [ ] All skills tested with superpowers:writing-skills (RED-GREEN-REFACTOR)
- [ ] Changes documented in commit message
- [ ] No sensitive data in files

**Version Update (MANDATORY - all three files):**
- [ ] Update `.claude-plugin/plugin.json` → `version`
- [ ] Update `.claude-plugin/marketplace.json` → `metadata.version`
- [ ] Update `.claude-plugin/marketplace.json` → `plugins[0].version`
- [ ] Verify all four version locations match the target release version

**Git Operations:**
- [ ] Stage all changes: `git add .`
- [ ] Commit with descriptive message including changelog
- [ ] Push to main: `git push`
- [ ] Create git tag: `git tag v{VERSION} -m "Release message"`
- [ ] Push tag: `git push origin v{VERSION}`

**Verification:**
- [ ] Verify tag on GitHub points to commit with all version files
- [ ] Check plugin.json in tagged commit has correct version
- [ ] Check marketplace.json in tagged commit has correct versions (both fields)
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

# 1. Update ALL version files (manually edit)
#    - .claude-plugin/plugin.json → version
#    - .claude-plugin/marketplace.json → metadata.version
#    - .claude-plugin/marketplace.json → plugins[0].version
# 2. Stage and commit
git add .claude-plugin/plugin.json .claude-plugin/marketplace.json skills/
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

If you forget to update version files before tagging:

```bash
# 1. Delete the tag locally and remotely
git tag -d v{VERSION}
git push origin :refs/tags/v{VERSION}

# 2. Update ALL version files
# Edit .claude-plugin/plugin.json → version
# Edit .claude-plugin/marketplace.json → metadata.version
# Edit .claude-plugin/marketplace.json → plugins[0].version

# 3. Commit the fix
git add .claude-plugin/plugin.json .claude-plugin/marketplace.json
git commit -m "Fix version sync: Update all version files to {VERSION}"
git push

# 4. Recreate the tag (now points to commit with correct versions)
git tag v{VERSION} -m "v{VERSION}: Description"
git push origin v{VERSION}
```

## File Structure

```
agentDevPrompts/
├── .claude-plugin/
│   ├── plugin.json             # VERSION MUST MATCH GIT TAG
│   └── marketplace.json        # BOTH VERSION FIELDS MUST MATCH GIT TAG
├── skills/                     # Skills directory
│   ├── feature-researching/
│   │   └── SKILL.md
│   ├── feature-planning/
│   │   └── SKILL.md
│   ├── feature-implementing/
│   │   └── SKILL.md
│   ├── feature-documenting/
│   │   └── SKILL.md
│   ├── feature-finishing/
│   │   └── SKILL.md
│   ├── feature-pr-reviewing/
│   │   └── SKILL.md
│   └── feature-pr-fixing/
│       └── SKILL.md
├── CLAUDE.md                   # This file (development guidelines)
├── PUBLISHING.md               # Detailed publishing guide
└── README.md                   # User-facing documentation
```

## Version File Structure

**CRITICAL**: Three version fields across two files must be synchronized:

**plugin.json:**
```json
{
  "name": "feature-workflow",
  "version": "1.2.0",  // ← MUST match git tag
  ...
}
```

**marketplace.json:**
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
- Update ALL THREE version fields:
  - plugin.json → version
  - marketplace.json → metadata.version
  - marketplace.json → plugins[0].version

## Filename Sanitization Rules

All skills must follow these standardized rules for creating temporary workflow files:

### Feature Names (Code-Related)
**Used by:** feature-researching, feature-planning, feature-implementing, feature-finishing
**Files:** Z01_*.md, Z02_*.md, Z05_*.md

**Rules:**
- Use snake_case: lowercase with underscores
- Replace spaces and special chars with underscores
- Remove quotes, slashes, colons
- Truncate to 50 characters
- **Example:** "OAuth 2.0 Authentication!" → "oauth_2_0_authentication"

### PR Titles (User-Generated)
**Used by:** feature-pr-reviewing, feature-pr-fixing
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

### CRITICAL: Naming and Description Guidelines

**NEVER name commands and skills identically.** This causes name collision where agents load command descriptions instead of skills.

**Naming Convention:**
- **Skills** use gerund form: `feature-researching`, `feature-planning` (describes the capability)
- **Commands** use imperative form: `/feature-research`, `/feature-plan` (describes the action)
- **Why:** Prevents name collision, makes the relationship clear (command invokes skill)

**Relationship:**
- Commands reference and invoke skills
- Skills contain the actual workflow logic
- Commands should be thin wrappers that just invoke the skill

**Description Guidelines:**

**DO:**
- Keep descriptions deliberately vague and minimal
- Force agents to read the full skill/command to understand the workflow
- Use pattern: "Use when [trigger] - [minimal outcome]"
- Example: "Use when reviewing pull request changes - follow structured workflow"

**DON'T:**
- Provide step-by-step details in descriptions
- Explain HOW the workflow works
- Give enough information for agents to "jump to conclusions"
- Example (BAD): "Use when reviewing PRs - analyzes with feature-researching, presents findings, offers user choices for commenting or documentation"

**Why:** Detailed descriptions allow agents to think they understand without reading the skill, leading to violations of the actual workflow. Vague descriptions force thorough reading.

**Command Files:**
- Should simply state: "Use the [plugin]:[skill-name] skill exactly as written"
- No additional explanation or workflow details

**Skill Writing Philosophy:**

Unless instructed otherwise, give agents freedom when writing skills:
- **Default to WHAT, not HOW:** Tell agents what needs to be accomplished, not how to do it
- **Trust agent judgment:** Let agents choose implementation approaches unless specific constraints are needed
- **Only prescribe HOW when necessary:** Use rigid steps/checklists only when:
  - Preventing known failure modes
  - Enforcing critical project patterns
  - Maintaining consistency across the workflow
- **Example WHAT:** "Create a comprehensive test suite covering edge cases"
- **Example HOW:** "Run pytest, fix failures, commit with message format X"

**When to use prescriptive (HOW) vs declarative (WHAT):**
- **Prescriptive (HOW):** File naming, git operations, workflow steps, integration points
- **Declarative (WHAT):** Code quality, architecture decisions, testing approaches, implementation details

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
- ALWAYS update ALL version files (plugin.json + marketplace.json) before tagging
- ALWAYS verify version synchronization across all three fields
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
- Tag a release without updating ALL version files first (plugin.json + marketplace.json)
- Update only some version fields (must update all three: plugin.json + both marketplace.json fields)
- Edit skills without running RED-GREEN-REFACTOR testing
- Create hypothetical rationalization tables (must come from real agent testing)
- Skip release checklist steps
- Assume "minor changes" don't need testing

## Common Rationalizations

| Excuse | Reality |
|--------|---------|
| "Just a version bump, skip checklist" | Version sync is CRITICAL. Follow checklist. |
| "I'll update plugin.json in the next commit" | Tag will point to wrong commit. Update ALL files BEFORE tagging. |
| "Marketplace.json can be updated later" | Tag will point to wrong commit. Update BEFORE tagging. |
| "Minor doc fix, no need to test" | Untested changes break in production. ALWAYS test. |
| "I'll remember all three version fields next time" | You'll forget under pressure. Use TodoWrite checklist. |
| "Users can wait for v1.2.1 to fix version" | Broken releases damage trust. Get it right first time. |

## Red Flags - STOP and Fix

When releasing a version:
- Did NOT update ALL version files (plugin.json + marketplace.json) before creating tag
- Updated only some version fields (missing plugin.json or one of the marketplace.json fields)
- Skipped testing skills before release
- No TodoWrite checklist for release steps
- Git tag version doesn't match all three version fields

**All of these mean:** Stop, fix synchronization, recreate tag correctly.

## Testing Before Release

**Local Testing:**
```bash
# Use symlinks for development
ln -s ~/Projects/Personal/prompts/skills/feature-researching ~/.claude/skills/feature-researching
ln -s ~/Projects/Personal/prompts/skills/feature-planning ~/.claude/skills/feature-planning
ln -s ~/Projects/Personal/prompts/skills/feature-implementing ~/.claude/skills/feature-implementing
ln -s ~/Projects/Personal/prompts/skills/feature-documenting ~/.claude/skills/feature-documenting
ln -s ~/Projects/Personal/prompts/skills/feature-finishing ~/.claude/skills/feature-finishing
ln -s ~/Projects/Personal/prompts/skills/feature-pr-reviewing ~/.claude/skills/feature-pr-reviewing
ln -s ~/Projects/Personal/prompts/skills/feature-pr-fixing ~/.claude/skills/feature-pr-fixing

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

1. **Version Synchronization**: Git tag MUST match ALL THREE version fields:
   - `.claude-plugin/plugin.json` → `version`
   - `.claude-plugin/marketplace.json` → `metadata.version`
   - `.claude-plugin/marketplace.json` → `plugins[0].version`
2. **Testing Before Release**: Skills MUST be tested with RED-GREEN-REFACTOR

**When releasing:**
- Use TodoWrite for release checklist
- Update ALL THREE version fields BEFORE creating tag
- Verify synchronization before pushing
- Test skills before committing

**The checklist exists because humans (and agents) forget under pressure.**
