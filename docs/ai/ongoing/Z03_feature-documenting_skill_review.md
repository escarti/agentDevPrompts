# Feature-Documenting Skill Review Findings

**Date**: 2026-02-17
**Reviewed file**: `skills/feature-documenting/SKILL.md`
**Method**: Headless Codex subagent review (`codex --yolo exec`)

## Findings

1. [HIGH] `skills/feature-documenting/SKILL.md:13`
Issue: Skill mandates `TodoWrite` as required first action, but this Codex environment uses `update_plan`.
Impact: Workflow can fail immediately because the required tool is unavailable.
Recommended fix: Replace `TodoWrite` instructions/examples with `update_plan` equivalents.

2. [HIGH] `skills/feature-documenting/SKILL.md:221`
Issue: Skill uses `AskUserQuestion` schema/tool name that does not match available tooling.
Impact: Decision-gate step becomes non-executable.
Recommended fix: Rewrite to `request_user_input` format where available, and add explicit fallback when unavailable.

3. [HIGH] `skills/feature-documenting/SKILL.md:170`
Issue: Cleanup deletes `Z01_*` to `Z05_*` across the entire `ONGOING_DIR`.
Impact: Can remove unrelated ongoing artifacts for other features.
Recommended fix: Delete only files tied to the current feature slug or the exact files discovered earlier in the workflow.

4. [MED] `skills/feature-documenting/SKILL.md:66`
Issue: Path scan includes `.ai/ongoing` and `docs/ongoing` despite repo guidance standardizing on `docs/ai/ongoing/`.
Impact: Inconsistent artifact placement and missed-file behavior.
Recommended fix: Use `docs/ai/ongoing/` as repository default, with override only when explicitly configured.

5. [MED] `skills/feature-documenting/SKILL.md:216`
Issue: `gh pr view --json ...` is used without explicit no-PR error handling.
Impact: Step flow may break on command failure before branching to the “no PR exists” path.
Recommended fix: Add exit-code handling and branch logic for PR-found vs PR-not-found.

## Raw subagent output source
- `.codex-subagents/feature-documenting-review.log`
