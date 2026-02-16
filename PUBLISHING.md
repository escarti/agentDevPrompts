# Publishing Guide

## Purpose

This repository supports two distribution variants:
- Claude Code marketplace plugin (`feature-workflow`)
- Codex local/installer-based skills (no marketplace)

Use the variant that matches the user request.

## Common Prerequisites

1. Repository: `git@github.com:escarti/agentDevPrompts.git`
2. Skills and command wrappers validated locally
3. `README.md`, `CLAUDE.md`, and `AGENTS.md` aligned with current behavior

## Variant A: Claude Marketplace Release

Use when the goal is to release a new Claude plugin version.

### Required Version Sync (before tagging)

Synchronize all 3 JSON version fields:
1. `.claude-plugin/plugin.json` -> `version`
2. `.claude-plugin/marketplace.json` -> `metadata.version`
3. `.claude-plugin/marketplace.json` -> `plugins[0].version`

Then create matching git tag `vX.Y.Z`.

### Steps

```bash
# 1) Edit version fields above

# 2) Commit
git add .claude-plugin/plugin.json .claude-plugin/marketplace.json skills commands README.md CLAUDE.md
git commit -m "vX.Y.Z: release feature-workflow updates"

# 3) Push
git push

# 4) Tag and push tag
git tag -a vX.Y.Z -m "Release vX.Y.Z"
git push origin vX.Y.Z
```

### Installation/Update (Claude)

```bash
/plugin marketplace add escarti/agentDevPrompts
/plugin install feature-workflow@agentDevPrompts
/plugin update feature-workflow
```

## Variant B: Codex Skills Release

Use when the goal is to publish/update Codex-usable skills. Codex does not use plugin marketplaces.

### What to Version

- Source of truth is `skills/*/SKILL.md` (and optionally `commands/*.md` docs).
- Git tags/releases are optional but recommended for stable install targets.
- Do not require `.claude-plugin/*` version bumps unless explicitly also doing Claude marketplace release.

### Steps

```bash
# 1) Commit skill/command/docs changes
git add skills commands README.md AGENTS.md
git commit -m "skills: update feature workflow for Codex"

# 2) Push
git push

# 3) Optional: tag for stable installer target
git tag -a vX.Y.Z -m "Codex skills vX.Y.Z"
git push origin vX.Y.Z
```

### Installation/Update (Codex)

Use Codex skill installer against this repository skills path:

```text
Use the skill-installer skill to install these skills https://github.com/escarti/agentDevPrompts/tree/main/skills/*
```

After install/update, restart Codex if needed to reload skills.

## Testing Before Any Release

- Verify each changed skill executes its expected workflow
- Verify superpowers-dependent skills still require `load-superpowers`
- Ensure artifact conventions remain consistent (`docs/ai/ongoing/`, `Z01`-`Z05`)

## Versioning Guidance

Use semantic versioning for tags:
- Major: breaking workflow/interface changes
- Minor: new capability
- Patch: fixes/docs/wording updates

If releasing Claude marketplace variant, tag version must match synchronized marketplace/plugin versions.

