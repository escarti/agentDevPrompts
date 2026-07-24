---
name: load-superpowers
description: Bootstrap marketplace Superpowers before using repository workflows that depend on them.
---

# Feature Workflow: Load Superpowers

Use this skill before any repository workflow that depends on marketplace Superpowers:
- `feature-researching`
- `feature-planning`
- `feature-implementing`
- `feature-finishing`
- `feature-pr-reviewing`
- `feature-pr-fixing`
- `fixing-small-issues`

## Purpose

This skill is a dependency loader. It makes the Superpowers source explicit before the repository workflow begins.

## Rules

1. Load `superpowers:using-superpowers` immediately before taking any other workflow action.
2. After that bootstrap step, load only the Superpowers skills relevant to the target workflow.
3. Superpowers for this repository must come from the marketplace/plugin system, not from a local checkout.
4. If `superpowers:using-superpowers` is unavailable, stop and report that the marketplace-installed Superpowers dependency is missing.
5. Do not reference or fall back to legacy local paths such as `~/.codex/superpowers`.

For `fixing-small-issues`, keep the coordinator context light:
- load `superpowers:using-superpowers` in the coordinator;
- load `superpowers:systematic-debugging` inside each Phase 1 sub-agent;
- load `superpowers:test-driven-development` and `superpowers:verification-before-completion` inside each Phase 2 sub-agent;
- do not load Phase-specific skill bodies into the coordinator merely to relay their work.

## Success Criteria

- Loaded `superpowers:using-superpowers` first
- Used marketplace/plugin Superpowers rather than a local clone
- Continued into the requested repository workflow only after the dependency was available
- Kept Phase-specific Superpowers loading inside `fixing-small-issues` sub-agents
