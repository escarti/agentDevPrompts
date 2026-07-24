# Feature Workflow - Claude Code Skills

Research-driven feature development and streamlined small-fix workflows for Claude Code, with superpowers integration for planning, implementation, QA review, finishing, and PR handling.

## Included Skills

Core workflow:
- `feature-researching` (requires superpowers)
- `feature-planning` (requires superpowers)
- `feature-implementing` (requires superpowers)
- `feature-qa-review` (requires superpowers)
- `feature-documenting` (standalone)

Quality and PR workflow:
- `feature-finishing` (requires superpowers)
- `feature-pr-reviewing` (requires superpowers)
- `feature-pr-fixing` (requires superpowers)

Bootstrap helper:
- `load-superpowers` (loads required superpowers skills before feature-* skills that depend on them)

Utility:
- `use-sub-agent` (orchestrates headless `codex --yolo exec` subagents with safe parallel/log patterns)

Small-fix workflow:
- `fixing-small-issues` (requires superpowers; coordinates two isolated diagnosis/fix phases)

## Dependencies

Install [superpowers](https://github.com/obra/superpowers) from the marketplace/plugin system for:
- `feature-researching`
- `feature-planning`
- `feature-implementing`
- `feature-qa-review`
- `feature-finishing`
- `feature-pr-reviewing`
- `feature-pr-fixing`
- `fixing-small-issues`

`feature-documenting` is standalone.

```bash
# In Claude Code
/plugin marketplace add obra/superpowers
/plugin install superpowers@obra/superpowers
```

`load-superpowers` is a compatibility shim for these workflow skills. It now assumes `superpowers:*` skills are provided by the marketplace install and no longer bootstraps from a local `~/.codex/superpowers` checkout.

Run `load-superpowers` before:
- `feature-researching`
- `feature-planning`
- `feature-implementing`
- `feature-qa-review`
- `feature-finishing`
- `feature-pr-reviewing`
- `feature-pr-fixing`
- `fixing-small-issues`

## Installation

### Option 1: Claude Code Marketplace (Recommended)

```bash
# In Claude Code
/plugin marketplace add escarti/agentDevPrompts
/plugin install feature-workflow@agentDevPrompts
```

Verify:
```bash
/help
```

Expected commands:
- `/feature-research`
- `/feature-plan`
- `/feature-implement`
- `/feature-qa-review`
- `/feature-document`
- `/feature-finish`
- `/feature-prreview`
- `/feature-prfix`
- `/fix-small-issue`

### Option 2: Manual Skill Symlinks (Development)

```bash
git clone git@github.com:escarti/agentDevPrompts.git ~/Projects/Personal/agentDevPrompts

ln -s ~/Projects/Personal/agentDevPrompts/skills/feature-researching ~/.claude/skills/feature-researching
ln -s ~/Projects/Personal/agentDevPrompts/skills/feature-planning ~/.claude/skills/feature-planning
ln -s ~/Projects/Personal/agentDevPrompts/skills/feature-implementing ~/.claude/skills/feature-implementing
ln -s ~/Projects/Personal/agentDevPrompts/skills/feature-qa-review ~/.claude/skills/feature-qa-review
ln -s ~/Projects/Personal/agentDevPrompts/skills/feature-documenting ~/.claude/skills/feature-documenting
ln -s ~/Projects/Personal/agentDevPrompts/skills/feature-finishing ~/.claude/skills/feature-finishing
ln -s ~/Projects/Personal/agentDevPrompts/skills/feature-pr-reviewing ~/.claude/skills/feature-pr-reviewing
ln -s ~/Projects/Personal/agentDevPrompts/skills/feature-pr-fixing ~/.claude/skills/feature-pr-fixing
ln -s ~/Projects/Personal/agentDevPrompts/skills/fixing-small-issues ~/.claude/skills/fixing-small-issues
ln -s ~/Projects/Personal/agentDevPrompts/skills/load-superpowers ~/.claude/skills/load-superpowers
ln -s ~/Projects/Personal/agentDevPrompts/skills/use-sub-agent ~/.claude/skills/use-sub-agent
```

These symlinks install only `feature-workflow`. Superpowers remains a separate marketplace dependency; do not point this setup at a local `~/.codex/superpowers` clone.

### Option 3: Codex Skill Installer

In Codex, paste and run this command to install all workflow skills from this repository:

```text
Use the skill-installer skill to install these skills https://github.com/escarti/agentDevPrompts/tree/main/skills/*
```

Restart Codex to pick up new skills.

## Migrating Off Legacy Local Superpowers

Older setups may still have a local Superpowers checkout at `~/.codex/superpowers`. This repository no longer uses that path.

After confirming the marketplace-installed `superpowers:*` skills resolve correctly through `load-superpowers`, remove only the legacy Superpowers assets:

```bash
rm -rf ~/.codex/superpowers
find ~/.codex/skills -maxdepth 1 \( -type l -o -type d \) | rg '/superpowers$'
```

Keep the `feature-workflow` entries in `~/.codex/skills` such as `feature-researching`, `feature-planning`, `feature-implementing`, `feature-qa-review`, `fixing-small-issues`, `load-superpowers`, and `use-sub-agent`. Those are separate from the legacy Superpowers checkout and should continue to point at this repository.

## Workflow

1. Start with `feature-workflow:feature-researching`
2. Plan with `feature-workflow:feature-planning`
3. Implement with `feature-workflow:feature-implementing`
4. Pass the mandatory fresh gate with `feature-workflow:feature-qa-review`
5. Finalize documentation and publish with `feature-workflow:feature-finishing`
6. Optionally consolidate temporary artifacts with `feature-workflow:feature-documenting`

The implementation-to-publication chain is enforced, not advisory. `feature-implementing` must invoke QA and cannot invoke finishing directly. QA records a `PASS` or `BLOCKED` verdict for one exact commit in `Z06`; any finding or later implementation change requires a complete fresh QA run. Only an explicitly accepted clean `PASS` may launch finishing. Finishing then audits documentation, records the change, obtains final publication approval, pushes without force, and opens a ready-for-review PR against `main`.

### Quick Guide (Intended Use)

| Stage | Use this | Goal | Input | Output |
| --- | --- | --- | --- | --- |
| Streamlined small fixes | `feature-workflow:fixing-small-issues` | Reproduce, diagnose, fix, commit, and verify through two context-isolated phases | GitHub issue or direct misbehavior report | Verified commit on a `bugfix/*` branch |
| 1. Single entry point: idea triage + repo-grounded research | `feature-workflow:feature-researching` | Act as an evidence-led sparring partner: investigate the repo, surface unresolved product and technical bifurcations, and create research only after the user resolves them | Rough idea, partial spec, or detailed request | Complete `Z01_*_research.md` |
| 2. Ambiguity-free planning | `feature-workflow:feature-planning` (wrapper of superpowers `writing-plans`) | Convert clear spec + research into an actionable implementation plan, then optionally publish the approved plan into GitHub issues or a Jira epic plus tasks | Complete Z01 research | `Z02_*_plan.md` (final), optional temporary `Z02_CLARIFY_*_plan.md`, and optional approved tracker items |
| 3. Execution | `feature-workflow:feature-implementing` (wrapper of superpowers execution workflow) | Execute from the canonical Z02 plan with local `Z99` tracking, or execute tracker-natively from an approved published tracker graph | `Z02_*_plan.md` or approved tracker entrypoint | Implemented code + verification + mandatory QA handoff |
| 4. Commit-bound QA gate | `feature-workflow:feature-qa-review` | Run five isolated code-focused review profiles against one feature-branch commit and require a fresh clean result | Implemented code + tracker or Z01/Z02 context | Accepted `PASS` or `BLOCKED`, verification evidence, and `Z06_{feature}_qa_review.md` |
| 5. Documentation and publication gate | `feature-workflow:feature-finishing` | Validate the accepted QA commit, remove documentation drift, record changes, and publish only after final approval | Accepted clean Z06 + implementation and documentation context | `Z05_*`, finalization commit, pushed branch, and ready-for-review PR |
| 6. Optional artifact consolidation | `feature-workflow:feature-documenting` | Consolidate temporary workflow artifacts into a development log and update an existing PR when requested | Z-files and completed workflow results | Dev log, cleanup commit, and optional PR update |

`feature-researching` uses decision provenance at every definition level. A decision may be adopted when the prompt specifies it or repository evidence leaves no credible alternative. When multiple meaningful product or technical paths remain, research presents the evidence and repo patterns, viable options, consequences, and a recommendation, then asks the user to decide one bifurcation at a time.

Clarification happens live inside the research conversation. `feature-researching` does not create a `Z01_CLARIFY` question backlog or write a partial Z01. If the conversation pauses, research remains in progress and resumes at the unresolved decision. The final `Z01_*` artifact is created only after all known meaningful bifurcations are resolved.

`feature-researching` may still invoke `superpowers:brainstorming` internally for low-definition inputs or deeper product-level ambiguity. Brainstorming remains an internal refinement step: it can help shape the direction, but `feature-researching` still owns the stage, the live decision loop, and the canonical `Z01_*` artifact.

Use the full flow for large features where discovery, planning, and execution need strict structure.

### Small fixes

Use `feature-workflow:fixing-small-issues` or `/fix-small-issue` for a bounded bug, hotfix, regression, failing test, or small corrective change.

Do not use it for a new feature. If Phase 1 finds that the report is a missing capability rather than a defect, the workflow stops before Phase 2 implementation and routes to `feature-workflow:feature-researching`.

The workflow:
1. Creates or resumes a dedicated `bugfix/*` branch.
2. Runs a fresh diagnosis sub-agent that reproduces the issue and returns the root cause and fix options.
3. Runs a fresh implementation sub-agent that plans, tests, fixes, verifies, and commits.
4. Keeps the coordinator context small by retaining only structured checkpoints.
5. Allows at most three executions of either phase, blocking before a fourth.

It accepts a GitHub issue or a direct misbehavior report, creates no Z artifacts, and does not use the feature QA/finishing pipeline. GitHub issue comments remain one or two sentences.

Common temporary artifacts:
- `docs/ai/ongoing/Z01_{feature}_research.md`
- `docs/ai/ongoing/Z02_{feature}_plan.md`
- `docs/ai/ongoing/Z02_CLARIFY_{feature}_plan.md` (only when planning discovers new blockers)

Optional tracker publication after planning:
- `feature-planning` can preview and publish the approved `Z02_*_plan.md` into:
  - GitHub: one parent roadmap issue plus one child issue per Z02 task
  - Jira: one epic plus one task per Z02 task
- Publication is never automatic. The workflow previews destination, tasks, and dependencies first and waits for explicit approval before mutation.
- `Z02_*_plan.md` remains the canonical local planning artifact even when tracker items are published. Tracker items are a projection of the approved Z02, not a separate planning flow.
- Published tracker items must be self-contained. They must not rely on links to `Z0X` workflow files, local file paths, or other transient local artifacts for required implementation context.
- GitHub publication uses a strict title pattern for easy scanning:
  - parent issue: `[Epic] <feature name>`
  - child issue: `[Task X.Y][Parent #N] <task title>`

Implementation mode after planning:
- Local-plan execution keeps `Z02_*_plan.md` as source of truth and `Z99_implementation_status.md` as the live execution tracker.
- Local-plan execution requires one validated, attributable commit per completed Z02 task on the feature branch.
- Tracker execution is tracker-native. It must not create or rely on `Z99`.
- Tracker execution uses one branch per parent roadmap issue or epic.
- Tracker execution defaults to one child issue/task per batch so commit attribution stays unambiguous.
- In tracker execution, one completed child issue or task corresponds to one validated commit on that branch.
- Those commits must already exist before the workflow asks the user whether to continue with the next batch.
- Batching does not relax commit isolation: by the end of implementation, the feature branch must contain at least one attributable, followable commit per Z02 task or published child issue/task, with additional fix commits allowed when needed.
- A tracker child item is done only after the workflow validates the returned commit SHA on the epic branch and verification was reported.
- After the local-plan or tracker completion gate passes, implementation must invoke `feature-qa-review` and must not invoke or suggest `feature-finishing` directly.

QA and finishing gates:
- QA binds the review to the full current commit SHA and runs bug, security, plan-conformance, test-gap, and maintainability profiles in isolation.
- Any finding makes that QA run `BLOCKED`, regardless of severity or whether it is fixed immediately.
- Fixes and any other implementation changes require a new commit and a complete fresh five-profile QA run.
- A clean `PASS` still requires explicit user acceptance before QA can invoke finishing.
- Finishing checks the accepted Z06 and reviewed commit before editing documentation.
- Finishing owns documentation consistency and change recording; it does not repeat QA's code-review profiles.
- Any required non-documentation change stops finishing and routes the work back through fresh QA.
- Finishing stages only intended files, asks for explicit publication approval, pushes without force, and opens a ready-for-review PR against `main`.

Clarification gates:
- Research stays conversational and does not create Z01 while meaningful product or technical bifurcations remain unresolved.
- Planning is not complete while `Z02_CLARIFY_*_plan.md` has unresolved questions.
- The workflow must stay in the current stage and wait; research resumes the live sparring loop, while planning incorporates its clarify items and removes or empties the Z02 clarify file.

Additional temporary artifacts may be created in PR/finish flows:
- `Z03_*`, `Z04_*`, `Z05_*` in the same ongoing directory
- `Z06_{feature}_qa_review.md` for the commit-bound QA verdict, verification, findings, and user acceptance

## Prompt Install Scripts (Codex and Copilot)

This repository also includes scripts for legacy prompt files (`A01_*`, `A02_*`, `A03_*`):
- `install_codex.sh`: copies prompts to `~/.codex/prompts`
- `install_copilot_prompts.sh`: installs prompts to VS Code User prompts directory as `*.prompt.md`
- `create_symlink_prompt.sh`: symlinks prompts into `.prompts/` in the current repo and updates `.gitignore`
- `install_symlink.sh`: installs `add_prompts` command in `~/.local/bin` pointing to `create_symlink_prompt.sh`

Command/prompt compatibility:
- `prompts/*.md` are symlinks to `commands/*.md`
- Run `./scripts/sync_prompts_from_commands.sh` after adding/removing command files

## Repository Structure

```text
agentDevPrompts/
├── .claude-plugin/
│   ├── marketplace.json
│   └── plugin.json
├── commands/
│   └── fix-small-issue.md
├── prompts/   (symlinks to commands for Codex prompt compatibility)
├── scripts/
├── skills/
│   ├── feature-researching/
│   ├── feature-planning/
│   ├── feature-implementing/
│   ├── feature-qa-review/
│   ├── feature-documenting/
│   ├── feature-finishing/
│   ├── feature-pr-reviewing/
│   ├── feature-pr-fixing/
│   ├── fixing-small-issues/
│   ├── load-superpowers/
│   └── use-sub-agent/
├── docs/
├── AGENTS.md
├── CLAUDE.md
├── scripts/sync_prompts_from_commands.sh
├── scripts/release.sh
├── PUBLISHING.md
└── README.md
```

## Development Notes

- `feature-planning` wraps superpowers `writing-plans`.
- `feature-implementing` wraps superpowers `executing-plans`.
- `feature-finishing` owns post-QA documentation consistency and approved ready-for-review PR publication.
- `feature-pr-fixing` leverages superpowers debugging workflows.
- `fixing-small-issues` handles bounded defects through isolated diagnosis and fix phases; the Z-artifact workflow and its QA/finishing gates remain for features.
- Keep version fields synchronized before release (see `AGENTS.md`, `CLAUDE.md`, and `PUBLISHING.md`).

## Attribution

This plugin builds on [superpowers](https://github.com/obra/superpowers) by [Jesse Vincent](https://github.com/obra). The feature-workflow skills add conversational research, structured planning artifacts, and workflow-specific orchestration around those core skills.

## License

MIT License - see [LICENSE](LICENSE).

## Changelog

See `CHANGELOG.md` for version-by-version release history.
