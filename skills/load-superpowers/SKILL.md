---
name: load-superpowers
description: Bootstrap superpowers and load required superpowers skills before using feature-* skills that require them.
---

## Superpowers System

<EXTREMELY_IMPORTANT>
Superpowers for this workflow must come from the marketplace/plugin system, not from a local checkout.
Immediately use `superpowers:using-superpowers` before any response, and follow its rules for loading and applying all relevant superpowers skills.

If `superpowers:using-superpowers` is unavailable, stop and report that the marketplace-installed Superpowers dependency is missing.
Do not reference or fall back to any legacy local path such as `~/.codex/superpowers`.
</EXTREMELY_IMPORTANT>
