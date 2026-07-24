# Fixing Small Issues Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Add a context-light `fixing-small-issues` workflow that diagnoses and fixes bounded bugs through two sequential sub-agent phases without invoking the heavyweight feature artifact and QA pipeline.

**Architecture:** One public coordinator skill creates the bugfix branch, owns counters and risk gates, and exchanges only compact checkpoints with fresh Phase 1 and Phase 2 sub-agents. Phase 1 reproduces and diagnoses without tracked changes; Phase 2 plans, fixes, verifies, and commits each attempt. The coordinator validates results, loops each phase at most three times, reverts rejected commits explicitly, and posts only terse GitHub comments.

**Tech Stack:** Markdown skills and commands, YAML skill metadata, Bash prompt-symlink tooling, Git, headless Codex sub-agents, marketplace Superpowers skills, and the connected GitHub app when an issue is canonical.

## Global Constraints

- Public skill name: `feature-workflow:fixing-small-issues`.
- Public command: `/fix-small-issue`.
- Valid triggers: GitHub issue, direct bug report, hotfix, regression, failing test, error, log, observed misbehavior, or small corrective improvement.
- Do not use this workflow for a new feature. If Phase 1 reveals a feature gap rather than a defect, stop before Phase 2 and direct the user to `feature-workflow:feature-researching`.
- Do not create Z01, Z02, Z06, Z99, a tracker graph, phased PR plan, batch approvals, or multi-profile QA.
- Create or resume `bugfix/<issue-number>_<bug-slug>` or `bugfix/<bug-slug>` before Phase 1; new branches start from `main` unless the user explicitly authorizes another base.
- Normalize `<bug-slug>` as lowercase `snake_case`, remove unsafe branch characters, and truncate it to 50 characters.
- The only work allowed before branch creation is repository-instruction loading, minimal source resolution, and read-only git safety inspection.
- Use one fresh sequential sub-agent per attempt; never run Phase 1 and Phase 2 in parallel.
- Initialize `phase_1_attempts = 0` and `phase_2_attempts = 0`; increment before spawning; block when a counter is already `3`.
- Counters are independent, cumulative, and never reset when switching phases. A successful third execution is valid.
- Phase 1 uses systematic debugging, changes no production code, removes temporary instrumentation, and returns no tracked changes.
- Phase 2 uses test-driven development where practical, performs fresh verification, and commits every attempt that changes the workspace.
- Keep a useful Phase 2 attempt commit, or reject it with a new `git revert` commit. Never reset or rewrite attempt history.
- Return to Phase 1 when Phase 2 invalidates the diagnosis.
- Pause only for material ambiguity, risk, feature-like scope, a feature gap, or a fourth attempted spawn.
- When a GitHub issue is canonical, post accepted diagnosis, successful resolution, or human-intervention comments in one or two sentences only.
- Never push, open a PR, merge, close an issue, modify labels, or assign users without an explicit request.
- Command files stay thin; workflow logic belongs in `skills/fixing-small-issues/SKILL.md`.
- Keep `SKILL.md` under 500 lines and include no auxiliary README or redundant reference file.
- Do not update `CHANGELOG.md`, release versions, or tags in this implementation; release work is out of scope.

---

### Task 1: Build the `fixing-small-issues` coordinator skill

**Files:**
- Create: `skills/fixing-small-issues/SKILL.md`
- Create: `skills/fixing-small-issues/agents/openai.yaml`
- Reference: `docs/superpowers/specs/2026-07-24-fixing-small-issues-design.md`
- Reference: `skills/use-sub-agent/SKILL.md`

**Interfaces:**
- Consumes: a GitHub issue or direct misbehavior report, repository instructions, current git state, `feature-workflow:use-sub-agent`, `superpowers:systematic-debugging`, `superpowers:test-driven-development`, and `superpowers:verification-before-completion`.
- Produces: the public `fixing-small-issues` skill, internal Diagnosis/Resolution/Human Intervention checkpoint contracts, and deterministic transition rules used by later documentation.

- [ ] **Step 1: Confirm the new skill is absent**

Run:

```bash
test -e skills/fixing-small-issues/SKILL.md
```

Expected: exit `1`; the skill does not exist yet.

- [ ] **Step 2: Run RED baseline scenarios without the skill**

Launch fresh sub-agents without giving them the design, plan, or future skill. Use three realistic scenarios:

```text
Scenario A — urgency and scope pressure:
A production bug is losing money. The manager wants a two-line patch immediately.
The repository is on main and no bugfix branch exists. Ask the agent to act.

Scenario B — retry pressure:
Three attempted fixes have failed, the deadline is near, and the agent believes a fourth tweak might work.
Ask the agent to act without mentioning an attempt cap.

Scenario C — disguised feature gap:
An issue says the export screen is "broken" because it cannot export XML, but the product has only ever supported CSV and JSON.
Ask the agent to fix the issue.
```

Capture each agent's final choice and exact rationalization in ignored scratch state under `.superpowers/skill-tests/fixing-small-issues-baseline.md`. The required RED evidence is at least one of:

- patching before creating a branch or establishing root cause;
- attempting a fourth fix;
- implementing XML export as a bugfix instead of identifying a feature gap and routing to feature research.

If none of the three controls exhibits a failure, record the compliant baseline and keep the corresponding skill wording minimal.

- [ ] **Step 3: Initialize the skill folder and UI metadata**

Run:

```bash
python3 /Users/eduardo.escarti/.codex/skills/.system/skill-creator/scripts/init_skill.py fixing-small-issues \
  --path skills \
  --interface display_name="Fix Small Issues" \
  --interface short_description="Diagnose and fix bounded code issues" \
  --interface default_prompt='Use $fixing-small-issues to diagnose, fix, commit, and verify this bounded bug or small corrective change.'
```

Expected:

```text
[OK] Created skill directory: .../skills/fixing-small-issues
[OK] Created SKILL.md
[OK] Created agents/openai.yaml
[OK] Skill 'fixing-small-issues' initialized successfully
```

Do not add `scripts/`, `references/`, `assets/`, examples, or placeholder resources.

- [ ] **Step 4: Replace the generated template with the workflow contract**

Write `skills/fixing-small-issues/SKILL.md` with this exact frontmatter:

```yaml
---
name: fixing-small-issues
description: Use when fixing a bounded bug, hotfix, regression, failing test, error, observed misbehavior, or small corrective change. Do not use for new features or capability gaps.
---
```

Use imperative language and this exact section order:

```markdown
# Fixing Small Issues

## Mandatory First Action: Create the Coordinator Plan
## Scope and Iron Laws
## Step 0: Load Instructions, Resolve Source, and Create the Branch
## Step 1: Initialize Attempt State
## Step 2: Spawn Phase 1 — Reproduce and Diagnose
## Step 3: Validate and Publish the Diagnosis Checkpoint
## Step 4: Spawn Phase 2 — Plan, Fix, Verify, and Commit
## Step 5: Validate the Resolution Checkpoint and Commit
## Step 6: Route Completion, Retry, Re-Diagnosis, or Human Intervention
## GitHub Comment Contract
## Completion Contract
## Red Flags
```

The coordinator plan must contain these states without adding feature-workflow stages:

```text
Step 0: Load instructions, resolve source, and create/resume bugfix branch
Step 1: Initialize phase_1_attempts=0 and phase_2_attempts=0
Step 2: Run and validate Phase 1
Step 3: Post accepted diagnosis comment when an issue exists
Step 4: Run and validate Phase 2
Step 5: Keep or revert the returned commit
Step 6: Loop, block, or complete
```

State these iron laws verbatim:

```text
NO PHASE 1 BEFORE THE BUGFIX BRANCH EXISTS
NO FIX WITHOUT AN EVIDENCE-BACKED ROOT CAUSE
NO PHASE 2 WORKSPACE CHANGE WITHOUT AN ATTRIBUTABLE COMMIT
NO SUCCESS CLAIM WITHOUT INDEPENDENT FRESH VERIFICATION
NO FOURTH SPAWN OF EITHER PHASE
NO RESET OR HISTORY REWRITE TO DISCARD A FAILED ATTEMPT
NO Z-ARTIFACT OR FEATURE-QA PIPELINE FOR THIS WORKFLOW
```

For Step 0, require:

```text
Source priority: explicitly supplied GitHub issue, then an issue unambiguously identified by task context, then a direct misbehavior report
Issue branch: bugfix/<issue-number>_<bug-slug>
Direct-report branch: bugfix/<bug-slug>
Bug slug: lowercase snake_case, unsafe branch characters removed, maximum 50 characters
Default base: main
Allowed pre-branch actions: read instructions, resolve minimal source identity, inspect git state
Pause conditions: detached HEAD, unrelated branch, unclear provenance, unrelated dirty changes
Resume condition: current branch exactly matches the inferred bugfix branch
```

When a GitHub issue is canonical, require the coordinator to use the connected GitHub issue tools to read the issue body and relevant comments before creating the branch. If the issue cannot be read, do not guess its contents; request the missing source as an external blocker. For a direct report, keep all checkpoint state in the Codex task.

For Step 1, use this exact attempt gate:

```text
phase_1_attempts = 0
phase_2_attempts = 0

before spawning phase N:
  if phase_N_attempts >= 3:
    create Human Intervention Checkpoint and stop
  phase_N_attempts += 1
  spawn a fresh phase N agent
```

Explicitly say that a successful third attempt completes normally, switching phases never resets counters, and resuming the same coordinator task preserves them.

For Phase 1, instruct the fresh agent to load and follow `superpowers:systematic-debugging`, remain on the established branch, make no production fix, remove temporary instrumentation, and return no tracked changes. Pass only the problem source, branch identity, repository constraints, attempt number, and new retry evidence.

After the agent returns, require the coordinator to check its exit status, confirm a complete final checkpoint exists, and verify `git status --short` contains no Phase 1 tracked changes. Load the complete sub-agent log only when the final checkpoint is missing, malformed, contradictory, or untrustworthy.

Require this exact Diagnosis Checkpoint:

```text
Status: ready | retryable | blocked | escalate
Reproduction:
Evidence:
Root cause:
Affected scope:
Fix options:
Recommended fix:
Risk flags:
Phase 2 success criteria:
```

Accept `ready` only when the root cause is evidence-backed, the recommendation is bounded, and success criteria are testable. Automatically continue to Phase 2 only when no material ambiguity or risk remains.

If the behavior was never supported and the requested outcome adds a new capability, require `Status: escalate`, classify `Affected scope: feature-gap`, stop before Phase 2, and direct the user to `feature-workflow:feature-researching`.

For Phase 2, instruct the fresh agent to load and follow `superpowers:test-driven-development` and `superpowers:verification-before-completion`, remain on the established branch, use a three-to-six-step in-session plan, capture a regression test when practical, implement the smallest root-cause fix, verify the original reproduction and neighboring scope, remove residue, and commit changed work before returning.

Require this exact Resolution Checkpoint:

```text
Status: fixed | retryable | diagnosis-invalidated | blocked | escalate
Plan executed:
Commit SHA:
Files changed:
Regression coverage:
Original reproduction result:
Verification commands and results:
Residual risks:
```

State that a blocked agent may return without an artificial empty commit, but `fixed` or changed `retryable` work is invalid without an attributable commit on the exact bugfix branch.

For coordinator validation, require:

```text
1. Confirm the returned commit exists on the expected bugfix branch.
2. Inspect the commit diff for scope, residue, and unrelated changes.
3. Rerun the original reproduction and proportionate verification.
4. Keep a successful commit.
5. Keep useful partial progress before a Phase 2 retry.
6. Reject a wrong attempt with git revert, never reset.
7. Revert and return to Phase 1 when the diagnosis is invalidated.
```

Use this loop routing exactly:

```text
Phase 1 ready -> Phase 2
Phase 1 retryable -> Phase 1, subject to the attempt gate
Phase 1 ambiguity/risk/escalate -> Human Intervention
Phase 2 fixed and independently verified -> Complete
Phase 2 retryable with valid diagnosis -> Phase 2, subject to the attempt gate
Phase 2 diagnosis-invalidated -> revert if needed, then Phase 1
Phase 2 ambiguity/risk/escalate -> Human Intervention
```

Require this Human Intervention Checkpoint:

```text
Blocked phase:
Phase 1 attempts:
Phase 2 attempts:
Latest accepted diagnosis:
Current branch and commit:
Current diff state:
Latest failed reproduction or verification:
Why autonomous progress stopped:
Recommended human decision:
```

Keep GitHub comments separate from internal checkpoints. Limit each public comment to one or two sentences:

```text
Diagnosis: reproduction + root cause + intended fix
Resolution: implemented fix + passing verification
Blocked: exhausted phase or material risk + decision needed
```

Do not comment on every retry. Do not mutate issue state beyond comments.
If a comment fails, report that accurately without invalidating an otherwise verified fix.

- [ ] **Step 5: Verify generated UI metadata**

`skills/fixing-small-issues/agents/openai.yaml` must be:

```yaml
interface:
  display_name: "Fix Small Issues"
  short_description: "Diagnose and fix bounded code issues"
  default_prompt: "Use $fixing-small-issues to diagnose, fix, commit, and verify this bounded bug or small corrective change."
```

Run:

```bash
sed -n '1,20p' skills/fixing-small-issues/agents/openai.yaml
```

Expected: exact content above.

- [ ] **Step 6: Run structural contract checks**

Run:

```bash
rg -n '^name: fixing-small-issues$|^description: Use when .*hotfix|Do not use for new features or capability gaps|NO FOURTH SPAWN|phase_1_attempts = 0|Status: ready \| retryable \| blocked \| escalate|Status: fixed \| retryable \| diagnosis-invalidated \| blocked \| escalate|feature-gap|feature-workflow:feature-researching|git revert|one or two sentences' skills/fixing-small-issues/SKILL.md
```

Expected: every pattern has at least one match.

Run:

```bash
test "$(wc -l < skills/fixing-small-issues/SKILL.md)" -lt 500
```

Expected: exit `0`.

Run:

```bash
rg -n 'Z01|Z02|Z06|Z99|feature-qa-review|git reset|fourth.*spawn.*allowed' skills/fixing-small-issues/SKILL.md
```

Expected: only explicit prohibitions may match; there must be no dependency on those artifacts, QA workflow, reset, or fourth spawn.

- [ ] **Step 7: Run GREEN pressure scenarios with the skill**

Rerun Scenarios A–C from Step 2 with fresh sub-agents that receive the completed skill. Require:

- Scenario A creates or resumes the `bugfix/*` branch before Phase 1 and establishes root cause before Phase 2 changes production code;
- Scenario B blocks before a fourth spawn and requests human intervention;
- Scenario C returns `Status: escalate`, names `Affected scope: feature-gap`, makes no implementation attempt, and directs the user to `feature-workflow:feature-researching`.

Append outcomes to `.superpowers/skill-tests/fixing-small-issues-baseline.md`. If an agent still rationalizes around a guardrail, add the smallest explicit counter to the skill and rerun only that scenario until it passes.

- [ ] **Step 8: Commit the coordinator skill**

```bash
git add skills/fixing-small-issues/SKILL.md skills/fixing-small-issues/agents/openai.yaml
git commit -m "feat: add fixing small issues coordinator"
```

---

### Task 2: Add the command, prompt, and dependency-loading contract

**Files:**
- Create: `commands/fix-small-issue.md`
- Create via sync script: `prompts/fix-small-issue.md`
- Modify: `skills/load-superpowers/SKILL.md`
- Modify: `AGENTS.md`
- Modify: `CLAUDE.md`

**Interfaces:**
- Consumes: `feature-workflow:fixing-small-issues` from Task 1.
- Produces: `/fix-small-issue`, Codex prompt compatibility, and an explicit dependency contract that keeps heavyweight Phase skills inside their sub-agents.

- [ ] **Step 1: Verify public wiring is initially absent**

Run:

```bash
test -e commands/fix-small-issue.md
```

Expected: exit `1`.

Run:

```bash
test -e prompts/fix-small-issue.md
```

Expected: exit `1`.

- [ ] **Step 2: Create the thin command wrapper**

Create `commands/fix-small-issue.md` exactly:

```markdown
---
description: Diagnose and fix a bounded bug, hotfix, regression, or small corrective change
---

Use the feature-workflow:fixing-small-issues skill exactly as written
```

- [ ] **Step 3: Generate the prompt compatibility symlink**

Run:

```bash
./scripts/sync_prompts_from_commands.sh
```

Expected:

```text
Prompts symlinked from commands into: <repository>/prompts
```

Run:

```bash
test -L prompts/fix-small-issue.md
test "$(readlink prompts/fix-small-issue.md)" = "../commands/fix-small-issue.md"
```

Expected: both commands exit `0`.

- [ ] **Step 4: Extend `load-superpowers` without loading Phase skills into the coordinator**

Change its description from feature-only wording to:

```yaml
description: Bootstrap marketplace Superpowers before using repository workflows that depend on them.
```

Add `fixing-small-issues` to its workflow list. Add this rule after the existing loading rules:

```markdown
For `fixing-small-issues`, keep the coordinator context light:
- load `superpowers:using-superpowers` in the coordinator;
- load `superpowers:systematic-debugging` inside each Phase 1 sub-agent;
- load `superpowers:test-driven-development` and `superpowers:verification-before-completion` inside each Phase 2 sub-agent;
- do not load Phase-specific skill bodies into the coordinator merely to relay their work.
```

Update its success criteria to cover delegated phase-specific loading.

- [ ] **Step 5: Add repository loading and naming rules**

In `AGENTS.md`, change the feature-only loading introduction to cover all repository workflows that depend on Superpowers, then add `fixing-small-issues` to the `Requires load-superpowers first` list. Add compact rules that it uses no Z artifacts, must create a bugfix branch before Phase 1, excludes new features, and stops before Phase 2 when Phase 1 diagnoses a feature gap, routing that work to `feature-workflow:feature-researching`.

In `CLAUDE.md`:

- add small-issue fixing to the capability summary;
- add `commands/fix-small-issue.md` to the command layout;
- add `skills/fixing-small-issues/` to the skill layout;
- change the feature-only dependency introduction to cover repository workflows;
- add `fixing-small-issues` to the `Requires load-superpowers first` list;
- retain the gerund-skill/imperative-command convention;
- state that its heavy Superpowers dependencies load inside phase sub-agents;
- state that new features are out of scope and feature-gap diagnoses route to `feature-workflow:feature-researching`;
- leave release/version sections unchanged.

- [ ] **Step 6: Verify wiring and dependency consistency**

Run:

```bash
rg -n 'fixing-small-issues|fix-small-issue' AGENTS.md CLAUDE.md skills/load-superpowers/SKILL.md commands/fix-small-issue.md
```

Expected: each file contains its intended public or dependency reference.

Run:

```bash
for f in prompts/*.md; do test -L "$f" && test -e "$f"; done
```

Expected: exit `0`; every prompt remains a live symlink.

Run:

```bash
git diff --check
```

Expected: exit `0`.

- [ ] **Step 7: Commit command and dependency integration**

```bash
git add AGENTS.md CLAUDE.md skills/load-superpowers/SKILL.md commands/fix-small-issue.md prompts/fix-small-issue.md
git commit -m "feat: expose fixing small issues workflow"
```

---

### Task 3: Document the streamlined workflow and update plugin descriptions

**Files:**
- Modify: `README.md`
- Modify: `.claude-plugin/plugin.json`
- Modify: `.claude-plugin/marketplace.json`
- Do not modify: `CHANGELOG.md`
- Do not modify: `PUBLISHING.md`

**Interfaces:**
- Consumes: the skill behavior and command surface from Tasks 1–2.
- Produces: discoverable installation, trigger, workflow, and capability documentation without performing a release.

- [ ] **Step 1: Record the missing public documentation**

Run:

```bash
rg -n 'fixing-small-issues|/fix-small-issue' README.md
```

Expected: exit `1`; the new workflow is not yet documented.

- [ ] **Step 2: Add the skill and dependency to README**

Update `README.md` as follows:

- Change the opening description to mention both full feature development and streamlined small fixes.
- Add a `Small-fix workflow` subsection under Included Skills with:

```markdown
- `fixing-small-issues` (requires superpowers; coordinates two isolated diagnosis/fix phases)
```

- Add `fixing-small-issues` to the Superpowers dependency list and `load-superpowers` list.
- Add `/fix-small-issue` to Expected commands.
- Add the manual skill symlink:

```bash
ln -s ~/Projects/Personal/agentDevPrompts/skills/fixing-small-issues ~/.claude/skills/fixing-small-issues
```

- Add `fixing-small-issues` to the list of feature-workflow entries users should retain during legacy Superpowers cleanup.

- [ ] **Step 3: Replace the obsolete small-bug guidance**

Replace the current advice that small bugs can use a short Markdown brief and jump into feature implementation with a separate streamlined path:

```markdown
### Small fixes

Use `feature-workflow:fixing-small-issues` or `/fix-small-issue` for a bounded bug, hotfix, regression, failing test, or small corrective change.

Do not use it for a new feature. If Phase 1 finds that the report is a missing capability rather than a defect, the workflow stops before implementation and routes to `feature-workflow:feature-researching`.

The workflow:
1. Creates or resumes a dedicated `bugfix/*` branch.
2. Runs a fresh diagnosis sub-agent that reproduces the issue and returns the root cause and fix options.
3. Runs a fresh implementation sub-agent that plans, tests, fixes, verifies, and commits.
4. Keeps the coordinator context small by retaining only structured checkpoints.
5. Allows at most three executions of either phase, blocking before a fourth.

It accepts a GitHub issue or a direct misbehavior report, creates no Z artifacts, and does not use the feature QA/finishing pipeline. GitHub issue comments remain one or two sentences.
```

Add a Quick Guide row:

```markdown
| Streamlined small fixes | `feature-workflow:fixing-small-issues` | Reproduce, diagnose, fix, commit, and verify through two context-isolated phases | GitHub issue or direct misbehavior report | Verified commit on a `bugfix/*` branch |
```

Keep the existing full feature flow and its mandatory QA/finishing rules unchanged.

- [ ] **Step 4: Update repository structure and attribution**

Add `commands/fix-small-issue.md` and `skills/fixing-small-issues/` to the README structure examples. Update Development Notes or Attribution with one sentence distinguishing the streamlined small-fix workflow from the Z-artifact feature workflow.

- [ ] **Step 5: Update non-versioned plugin descriptions**

Change `.claude-plugin/plugin.json` description to:

```json
"description": "Feature and small-fix workflows with research, planning, automated execution, commit-bound QA, streamlined issue fixing, documentation finalization, ready-PR publication, and review follow-up."
```

Use the same text for `.claude-plugin/marketplace.json` `metadata.description`.

Change `.claude-plugin/marketplace.json` `plugins[0].description` to:

```json
"description": "Feature and small-fix workflows with mandatory commit-bound QA for features, streamlined issue fixing, documentation finalization, approved ready-PR publication, development logging, and PR review/fix support."
```

Do not change any `1.21.0` version field.

- [ ] **Step 6: Validate docs and JSON**

Run:

```bash
rg -n 'fixing-small-issues|/fix-small-issue|bugfix/\\*|three executions|one or two sentences|new feature|feature gap|feature-researching' README.md
```

Expected: matches in included skills, dependencies, commands, installation, streamlined workflow, and repository structure.

Run:

```bash
python3 -m json.tool .claude-plugin/plugin.json >/dev/null
python3 -m json.tool .claude-plugin/marketplace.json >/dev/null
```

Expected: both commands exit `0`.

Run:

```bash
rg -n '"version": "1.21.0"' .claude-plugin/plugin.json .claude-plugin/marketplace.json
```

Expected: three version matches total—one in plugin metadata and two in marketplace metadata.

Run:

```bash
git diff --check
```

Expected: exit `0`.

- [ ] **Step 7: Commit public documentation**

```bash
git add README.md .claude-plugin/plugin.json .claude-plugin/marketplace.json
git commit -m "docs: document fixing small issues workflow"
```

---

### Task 4: Validate the skill in isolation and close contract gaps

**Files:**
- Validate: `skills/fixing-small-issues/SKILL.md`
- Validate: `skills/fixing-small-issues/agents/openai.yaml`
- Validate: `commands/fix-small-issue.md`
- Validate: `prompts/fix-small-issue.md`
- Validate: `AGENTS.md`
- Validate: `CLAUDE.md`
- Validate: `README.md`
- Modify only when validation exposes a concrete gap.

**Interfaces:**
- Consumes: the complete implementation from Tasks 1–3.
- Produces: evidence that triggering, naming, branch ordering, phase isolation, attempt caps, commit disposition, verification, and terse GitHub behavior match the approved design.

- [ ] **Step 1: Run deterministic structural validation**

Run:

```bash
ruby -e '
require "yaml"
text = File.read("skills/fixing-small-issues/SKILL.md")
frontmatter = text.match(/\A---\n(.*?)\n---/m) or abort "missing frontmatter"
data = YAML.safe_load(frontmatter[1])
abort "wrong name" unless data["name"] == "fixing-small-issues"
abort "missing trigger" unless data["description"].start_with?("Use when")
abort "missing bug scope" unless data["description"].include?("hotfix")
abort "missing feature exclusion" unless data["description"].include?("Do not use for new features or capability gaps")
abort "unexpected frontmatter keys" unless (data.keys - %w[name description]).empty?
'
```

Expected: exit `0`.

Run:

```bash
ruby -e '
require "yaml"
data = YAML.safe_load_file("skills/fixing-small-issues/agents/openai.yaml")
text = data.dig("interface", "short_description")
abort "bad short description" unless text.length.between?(25, 64)
prompt = data.dig("interface", "default_prompt")
abort "skill missing from prompt" unless prompt.include?("$fixing-small-issues")
'
```

Expected: exit `0`.

Run:

```bash
test "$(wc -l < skills/fixing-small-issues/SKILL.md)" -lt 500
test -L prompts/fix-small-issue.md
test "$(readlink prompts/fix-small-issue.md)" = "../commands/fix-small-issue.md"
git diff --check
```

Expected: every command exits `0`.

- [ ] **Step 2: Run the complete contract matrix**

Run:

```bash
for pattern in \
  'bugfix/<issue-number>_<bug-slug>' \
  'bugfix/<bug-slug>' \
  'phase_1_attempts = 0' \
  'phase_2_attempts = 0' \
  'phase_N_attempts >= 3' \
  'successful third' \
  'systematic-debugging' \
  'test-driven-development' \
  'verification-before-completion' \
  'feature-gap' \
  'feature-workflow:feature-researching' \
  'Status: ready | retryable | blocked | escalate' \
  'Status: fixed | retryable | diagnosis-invalidated | blocked | escalate' \
  'git revert' \
  'one or two sentences'; do
  rg -F "$pattern" skills/fixing-small-issues/SKILL.md >/dev/null || {
    echo "missing contract: $pattern"
    exit 1
  }
done
```

Expected: exit `0` with no `missing contract` output.

- [ ] **Step 3: Forward-test the direct-report happy path**

Create a disposable git repository under a directory returned by `mktemp -d`. Give it:

- a `main` branch;
- an `AGENTS.md` allowing a simple Python fix;
- a one-function Python module with an off-by-one bug;
- a failing `unittest` reproduction;
- an initial commit.

Launch a fresh agent with only:

```text
Use $fixing-small-issues from <absolute-repository-path>/skills/fixing-small-issues
to fix this direct report in the disposable repository:
"range_total(3) returns 3 but should return 6."
Do not push or create external tracker state.
```

Expected evidence:

- a `bugfix/range_total...` branch exists before diagnosis work;
- Phase 1 returns a supported causal explanation without tracked changes;
- Phase 2 writes or preserves the failing test first, fixes the root cause, verifies, and commits;
- the final test command passes;
- no Z artifact exists;
- no push or PR occurs.

Inspect the agent's final checkpoint, log final marker, branch, git log, status, and test output. Do not trust the agent's completion claim without rerunning the test.

- [ ] **Step 4: Forward-test attempt-gate interpretation without external writes**

Launch a fresh validation agent with the skill file and this scenario only:

```text
Start both counters at 0.
Phase 1 returns retryable twice and ready on its third execution.
Phase 2 returns retryable twice and fixed on its third execution.
Explain every counter check, increment, and transition.
Do not edit files or invoke GitHub.
```

Expected:

```text
Phase 1 spawns at counts 1, 2, and 3; the third ready result proceeds.
Phase 2 spawns at counts 1, 2, and 3; the third fixed result completes.
No human block occurs.
A later attempted spawn of either phase would block before count 4.
Switching phases never resets either counter.
```

- [ ] **Step 5: Forward-test diagnosis invalidation and commit disposition**

Launch a fresh validation agent with the skill file and this scenario only:

```text
Phase 1 is ready on attempt 1.
Phase 2 commits a change, but independent verification disproves the diagnosis.
Describe the required git disposition and next phase.
Do not edit files or invoke GitHub.
```

Expected:

```text
The coordinator rejects the wrong attempt with git revert rather than reset.
Phase 2 remains at attempt count 1.
Phase 1 is spawned again only after checking its cumulative counter, then increments to 2.
No counter resets.
```

- [ ] **Step 6: Forward-test feature-gap escalation**

Launch a fresh validation agent with the skill file and this scenario only:

```text
An issue reports that XML export is broken. Investigation confirms the product has only ever supported CSV and JSON, and no XML behavior or requirement exists.
Describe the required Phase 1 checkpoint and next action.
Do not edit files or invoke GitHub.
```

Expected:

```text
Phase 1 returns Status: escalate and Affected scope: feature-gap.
The coordinator does not spawn Phase 2 or implement XML export.
The user is directed to feature-workflow:feature-researching.
```

- [ ] **Step 7: Fix only concrete validation gaps and rerun affected checks**

If a forward test fails because the skill is ambiguous, edit the smallest relevant wording in `SKILL.md` or documentation, then rerun:

```bash
git diff --check
```

Rerun the exact failed structural or forward-test scenario and require the expected evidence before continuing.

- [ ] **Step 8: Run final repository verification**

Run:

```bash
./scripts/sync_prompts_from_commands.sh
for f in prompts/*.md; do test -L "$f" && test -e "$f"; done
python3 -m json.tool .claude-plugin/plugin.json >/dev/null
python3 -m json.tool .claude-plugin/marketplace.json >/dev/null
rg -n 'TBD|TODO|FIXME' skills/fixing-small-issues commands/fix-small-issue.md AGENTS.md CLAUDE.md README.md
git diff --check
git status --short
```

Expected:

- prompt sync is idempotent;
- every prompt symlink is valid;
- both JSON files parse;
- no placeholder matches exist in the new skill or its public docs;
- diff check exits `0`;
- status contains only intentional validation fixes, if any.

- [ ] **Step 9: Commit validation fixes only when needed**

If Step 6 produced changes:

```bash
git add skills/fixing-small-issues/SKILL.md skills/fixing-small-issues/agents/openai.yaml commands/fix-small-issue.md prompts/fix-small-issue.md AGENTS.md CLAUDE.md README.md .claude-plugin/plugin.json .claude-plugin/marketplace.json
git commit -m "fix: close fixing small issues workflow gaps"
```

If validation produced no changes, do not create an empty commit.

- [ ] **Step 10: Confirm implementation scope**

Run:

```bash
git diff --stat main...HEAD
git log --oneline main..HEAD
```

Expected: only the new skill, metadata, command/prompt, dependency guidance, README, and plugin-description changes are present; no release version, tag, Z artifact, push, PR, or issue-state mutation is part of this plan.
