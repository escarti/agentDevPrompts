# QA-Gated Finishing and Publication Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Enforce the workflow `feature-implementing -> accepted clean feature-qa-review -> documentation-focused feature-finishing -> approved push and ready-for-review PR`.

**Architecture:** Keep orchestration in the three workflow source skills. `feature-implementing` performs the mandatory QA handoff, `feature-qa-review` emits a commit-bound `PASS` or `BLOCKED` gate and launches finishing only after explicit acceptance, and `feature-finishing` validates that gate before documentation finalization and GitHub publication. Synchronize README, changelog, and QA skill metadata with those responsibilities.

**Tech Stack:** Markdown Codex skills, YAML skill metadata, Git/GitHub publication workflow, shell-based structural validation, isolated subagent pressure tests.

## Global Constraints

- Treat `skills/*/SKILL.md` as the source of truth; keep `commands/*.md` thin.
- Preserve the user's unrelated `docs/superpowers/specs/2026-07-22-feature-research-sparring-design.md` changes.
- Never permit a direct `feature-implementing -> feature-finishing` handoff.
- `feature-finishing` may run only after a user-accepted QA `PASS` tied to the reviewed code commit.
- Any QA finding or later non-documentation change blocks finishing and requires a complete fresh QA run.
- Publication requires explicit final approval, a non-force push, and a ready-for-review PR against `main`.
- Never stage unrelated worktree changes.

---

### Task 1: Establish the Failing Workflow Baseline

**Files:**
- Read: `skills/feature-implementing/SKILL.md`
- Read: `skills/feature-qa-review/SKILL.md`
- Read: `skills/feature-finishing/SKILL.md`
- Read: `docs/superpowers/specs/2026-07-22-qa-gated-finishing-publication-design.md`

**Interfaces:**
- Consumes: Current skill text and the approved design.
- Produces: Verbatim baseline observations identifying the direct-finishing shortcut, missing QA verdict contract, and duplicated finishing review responsibilities.

- [ ] **Step 1: Run an isolated no-guidance pressure scenario**

Dispatch a fresh subagent with the current skills and this decision prompt:

```text
Implementation has completed and all implementation tests pass. Choose and describe the next workflow stage. The user wants the fastest path to a PR and suggests running feature-finishing now. Follow the repository skills exactly and cite the binding handoff language.
```

- [ ] **Step 2: Verify the baseline exposes the defect**

Expected evidence includes at least one of:

```text
feature-implementing says finishing is optional/ready next
no binding requirement launches feature-qa-review
feature-finishing accepts completion directly after implementation
```

If the subagent already enforces the desired gate, stop and reassess because the pressure test did not reproduce the reported failure.

---

### Task 2: Make QA the Mandatory Post-Implementation Gate

**Files:**
- Modify: `skills/feature-implementing/SKILL.md`
- Modify: `skills/feature-qa-review/SKILL.md`
- Modify: `skills/feature-qa-review/agents/openai.yaml`

**Interfaces:**
- Consumes: The implementation completion gate and the branch/source context already resolved by `feature-implementing`.
- Produces: A mandatory QA invocation and a Z06 gate containing `Verdict`, `Reviewed Commit`, `User Acceptance`, verification evidence, and finding status.

- [ ] **Step 1: Add failing structural assertions for the intended handoff**

Run searches before editing and confirm they fail to find the new contract:

```bash
rg -n "accepted QA PASS|must not invoke.*feature-finishing|Reviewed Commit|User Acceptance|Verdict.*PASS.*BLOCKED" skills/feature-implementing/SKILL.md skills/feature-qa-review/SKILL.md
```

Expected: required contract phrases are absent or incomplete.

- [ ] **Step 2: Update `feature-implementing` minimally**

Add a final mandatory step after its existing completion gate that:

```text
invokes feature-workflow:feature-qa-review on the current feature branch;
passes branch, implementation source mode, feature slug, ongoing directory, and final implementation commit;
prohibits direct invocation of feature-finishing;
returns control without finishing when QA is blocked, interrupted, or unavailable.
```

Update its integration section, red flags, rationalization table, and success criteria so QA is the only valid next stage.

- [ ] **Step 3: Convert QA into a commit-bound verdict gate**

Revise the QA plan and workflow to:

```text
capture git rev-parse HEAD as Reviewed Commit;
run five isolated profiles (bug, security, plan conformance, test gaps, maintainability);
remove documentation consistency from QA;
run required verification;
emit PASS only when all profiles return No findings and verification passes;
emit BLOCKED for any finding, failed verification, unresolved decision, or stopped loop;
require a complete fresh rerun after any fix;
ask the user to accept a candidate PASS;
invoke feature-finishing only after explicit acceptance.
```

Expand Z06 with exact fields:

```markdown
**Verdict**: PASS | BLOCKED
**Reviewed Commit**: {full SHA}
**User Acceptance**: Accepted | Not accepted
**Verification**: {commands and outcomes}
```

- [ ] **Step 4: Synchronize QA UI metadata**

Update `skills/feature-qa-review/agents/openai.yaml` so its default prompt describes a commit-bound QA gate after implementation without summarizing an obsolete six-profile/documentation workflow.

- [ ] **Step 5: Run structural checks**

```bash
rg -n "feature-qa-review|must not.*feature-finishing|Reviewed Commit|User Acceptance|Verdict|five review profiles|fresh QA" skills/feature-implementing/SKILL.md skills/feature-qa-review/SKILL.md skills/feature-qa-review/agents/openai.yaml
git diff --check -- skills/feature-implementing/SKILL.md skills/feature-qa-review/SKILL.md skills/feature-qa-review/agents/openai.yaml
```

Expected: all gate concepts are present and `git diff --check` exits 0.

- [ ] **Step 6: Commit the QA gate changes**

```bash
git add skills/feature-implementing/SKILL.md skills/feature-qa-review/SKILL.md skills/feature-qa-review/agents/openai.yaml
git commit -m "feat: gate finishing on accepted QA"
```

---

### Task 3: Replace Duplicate Finishing Review with Documentation and Publication

**Files:**
- Modify: `skills/feature-finishing/SKILL.md`

**Interfaces:**
- Consumes: `Z06_{feature}_qa_review.md` containing an accepted `PASS` and reviewed code commit.
- Produces: `Z05_{feature}_finish.md`, documentation/finalization commit when needed, pushed feature branch, and ready-for-review PR URL.

- [ ] **Step 1: Add failing structural assertions for the finishing contract**

```bash
rg -n "accepted.*PASS|documentation drift|publication summary|ready-for-review|force-push|PR URL|non-documentation" skills/feature-finishing/SKILL.md
```

Expected: the current finishing skill does not satisfy the documentation/publication contract.

- [ ] **Step 2: Rewrite the finishing plan and prerequisites**

Replace adversarial, plan, PR-style, security, and generic finding-loop steps with:

```text
detect branch and code revision;
load matching Z06;
require Verdict: PASS and User Acceptance: Accepted;
verify the reviewed commit still identifies the current code revision;
stop and route to QA on a missing/stale/blocked gate;
load repository instructions and documentation surfaces;
audit documentation consistency and change recording;
apply documentation-only corrections;
invalidate QA if non-documentation implementation edits become necessary;
run final verification;
write Z05;
prepare finalization commit and publication preview;
ask for explicit final publication approval;
push without force and open a ready-for-review PR against main.
```

- [ ] **Step 3: Define documentation and worktree safety**

Require conditional checks for `README.md`, `AGENTS.md`, `CLAUDE.md`, `PUBLISHING.md`, `CHANGELOG.md`, commands, prompt links, skill metadata, plugin metadata, and user-facing API/install/configuration/migration docs. Require explicit path staging and forbid including unrelated user changes.

- [ ] **Step 4: Define publication behavior**

Require `gh --version`, authenticated GitHub access, remote/base/head resolution, fresh verification, explicit approval, `git push -u origin <branch>` without force, and creation of a non-draft PR. Prefer the available GitHub integration and allow `gh pr create` as fallback. Preserve local commits and worktree on failure.

- [ ] **Step 5: Update Z05 output contract**

Include:

```markdown
Accepted QA commit
documentation surfaces checked
drift found and fixes applied
verification commands and outcomes
publication approval
final commit SHA
pushed branch
ready-for-review PR URL
```

- [ ] **Step 6: Run structural checks**

```bash
rg -n "Z06|PASS|Accepted|documentation|CHANGELOG|publication approval|push|ready-for-review|PR URL|unrelated|force" skills/feature-finishing/SKILL.md
git diff --check -- skills/feature-finishing/SKILL.md
```

Expected: every finishing gate and safety concept is present and `git diff --check` exits 0.

- [ ] **Step 7: Commit the finishing rewrite**

```bash
git add skills/feature-finishing/SKILL.md
git commit -m "feat: turn finishing into publication gate"
```

---

### Task 4: Synchronize Repository Documentation and Validate Behavior

**Files:**
- Modify: `README.md`
- Modify: `CHANGELOG.md`
- Verify: `AGENTS.md`
- Verify: `CLAUDE.md`
- Verify: `PUBLISHING.md`
- Verify: `commands/feature-implement.md`
- Verify: `commands/feature-qa-review.md`
- Verify: `commands/feature-finish.md`

**Interfaces:**
- Consumes: Final contracts from Tasks 2 and 3.
- Produces: Public workflow documentation aligned with the enforced chain and pressure-test evidence that shortcut paths are rejected.

- [ ] **Step 1: Update public workflow documentation**

Change README descriptions so:

```text
implementation hands off only to QA;
QA is a fresh five-profile clean-verdict gate;
finishing is a documentation-consistency and ready-PR publication gate;
findings or non-documentation drift route back to a complete QA rerun.
```

- [ ] **Step 2: Record the unreleased behavior change**

Add concise `CHANGELOG.md` entries under the current unreleased `Changed` and `Fixed` sections describing the enforced QA handoff, removal of duplicated finishing review, and ready-for-review publication gate. Do not create a release or tag.

- [ ] **Step 3: Verify collateral surfaces**

Confirm `AGENTS.md`, `CLAUDE.md`, and `PUBLISHING.md` need no semantic updates beyond their existing skill/artifact listings. Confirm command wrappers remain thin and continue pointing at the source skills.

- [ ] **Step 4: Run updated pressure scenarios with isolated subagents**

Run at least these fresh-context cases with the revised skills:

```text
1. Completed implementation plus pressure to skip QA: must invoke QA and refuse finishing.
2. Z06 BLOCKED or containing any finding: finishing must stop.
3. Accepted PASS for an older code commit: finishing must stop and require fresh QA.
4. Accepted current PASS plus documentation drift: finishing may correct docs, then must request publication approval.
5. Mixed worktree with unrelated changes: finishing must stage only approved workflow files.
6. Publication approved: finishing must push without force and open a ready-for-review PR, preserving the worktree.
```

- [ ] **Step 5: Inspect every subagent result and close loopholes**

Compare decisions with the approved spec. If an agent rationalizes a shortcut, add the smallest explicit counter to the owning skill and rerun the failed scenario.

- [ ] **Step 6: Run final repository verification**

```bash
git diff --check
rg -n "optional finishing|six review profiles|documentation-consistency reviewer" skills README.md CHANGELOG.md
rg -n "feature-implementing.*feature-qa-review|accepted.*PASS|ready-for-review" README.md skills/feature-implementing/SKILL.md skills/feature-qa-review/SKILL.md skills/feature-finishing/SKILL.md
git status --short
```

Expected: no obsolete workflow claims in active documentation, required new contracts are present, formatting passes, and the unrelated user file remains outside implementation commits.

- [ ] **Step 7: Commit synchronized documentation**

```bash
git add README.md CHANGELOG.md
git commit -m "docs: document QA-gated PR workflow"
```
