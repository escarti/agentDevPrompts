---
name: load-superpowers
description: Bootstrap superpowers and load required superpowers skills before using feature-* skills that require them.
---

# Feature Workflow: Load Superpowers

Use this skill before any feature workflow that depends on marketplace Superpowers:
- `feature-researching`
- `feature-planning`
- `feature-implementing`
- `feature-finishing`
- `feature-pr-reviewing`
- `feature-pr-fixing`

## Purpose

This skill is a dependency loader. It makes the Superpowers source explicit before the feature workflow begins.

## Rules

1. Load `superpowers:using-superpowers` immediately before taking any other workflow action.
2. After that bootstrap step, load only the Superpowers skills relevant to the target workflow.
3. Superpowers for this repository must come from the marketplace/plugin system, not from a local checkout.
4. If `superpowers:using-superpowers` is unavailable, stop and report that the marketplace-installed Superpowers dependency is missing.
5. Do not reference or fall back to legacy local paths such as `~/.codex/superpowers`.

## Success Criteria

- Loaded `superpowers:using-superpowers` first
- Used marketplace/plugin Superpowers rather than a local clone
- Continued into the requested feature workflow only after the dependency was available
