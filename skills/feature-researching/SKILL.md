---
name: feature-researching
description: Use when beginning feature work from a rough idea, partial specification, or detailed request before implementation planning
---

# Feature Research

## YOU ARE READING THIS SKILL RIGHT NOW

**STOP. Before doing ANYTHING else:**

1. ☐ Create a progress plan (see below)
2. ☐ Mark Step 0 as `in_progress`

**This skill is the single feature-workflow entry point.**

Its responsibilities are:
- Triage the request, supplied references, and context needed to establish the intended feature
- Pass the triage context and evidence-collector contract to the installed `grilling` skill
- Install `grilling` from its approved source when it is absent, then require a fresh session before Step 0 can continue
- Produce and persist the settled grilling outcome as either `Z01_{feature}_research.md` or a GitHub issue titled `[Idea] <display feature name>`

**This skill produces a grounded feature specification, not an implementation plan.**

## MANDATORY FIRST ACTION: Create Progress Plan

```typescript
update_plan({
  "explanation": "Tracking feature research workflow",
  "plan": [
    {"step": "Step 0: Ensure required grilling dependency", "status": "in_progress"},
    {"step": "Step 1: Triage the request, supplied references, and relevant context", "status": "pending"},
    {"step": "Step 2: Run grilling with the triage context and evidence-collector contract", "status": "pending"},
    {"step": "Step 3: Assemble candidate research content without persisting it", "status": "pending"},
    {"step": "Step 4: Verify provenance, completeness, and the research/planning boundary", "status": "pending"},
    {"step": "Step 5: Choose and persist the validated research destination", "status": "pending"}
  ]
})
```

**After each step:** Mark completed, move `in_progress` to the next step.

## The Iron Law

```
NO MATERIAL DECISION OR REFERENCE USE WITHOUT CONFIRMED AUTHORITY
NO IMPLICIT MATERIAL ASSUMPTION WITHOUT STATING IT AND GETTING USER CONFIRMATION
NO PERSISTENCE OR HANDOFF WITH UNRESOLVED DECISIONS
NO CLARIFICATION ARTIFACT OR NON-SELF-CONTAINED RESEARCH SOURCE
```

**If the research payload depends on external docs for core requirements:** Copy or summarize the required source context into the payload and rewrite it to be self-contained.

## Decision Provenance Contract

Every material research decision must have one of these provenances:

1. **User-specified**: the initial prompt or a later user response selects the direction.
2. **Repository-determined**: repository instructions, documented contracts, or established constraints leave no credible alternative.
3. **Open bifurcation**: two or more credible paths remain after inspecting the prompt and repository evidence.

Adopt user-specified and repository-determined decisions. For every open bifurcation, investigate, recommend, and ask; do not choose.

Whenever interpreting missing or ambiguous information could affect scope, behavior, architecture, contracts, data, compatibility, security, operations, testing, or acceptance criteria, state the assumption and ask the user to confirm it, even if the interpretation appears obvious: “I’m assuming X because Y. Is that correct?” A confirmed answer becomes user-specified provenance. Do not turn routine mechanical facts into questions. Research cannot be persisted while a material implicit assumption remains unconfirmed.

Supplied references must be classified and confirmed individually before they influence research:
- **Light reference**: inspiration, examples, patterns, or ideas only. It establishes no requirement, fidelity, compatibility, or parity; anything borrowed is a proposal requiring explicit user acceptance.
- **Hard reference**: authoritative specification evidence. Its applicable behavior, contracts, data, UX, or operational characteristics are requirements unless the user explicitly excludes or changes them.

Propose the role from the user’s wording, then ask for confirmation. `1:1`, `copy exactly`, `port`, and `preserve parity` normally propose hard-reference treatment; `like`, `similar to`, `inspired by`, and `feel like` normally propose light-reference treatment. Ask separately for each supplied reference; do not silently give them equal authority.

A bifurcation is meaningful when its alternatives materially affect user-visible behavior, scope, architecture, component boundaries, APIs, schemas, persistence, security, permissions, privacy, failure behavior, compatibility, migration, operations, dependencies, delivery complexity, maintainability, testing strategy, acceptance criteria, or costly-to-reverse future flexibility.

This rule applies equally to product and technical decisions. Model confidence, a preferred recommendation, time pressure, or detailed wording does not establish provenance.

Routine facts and mechanically determined details are not bifurcations. Immaterial implementation details that are readily reversible belong in planning or implementation, not in a research assumption.

## Research Output Contract

**The persisted research payload is a grounded feature specification.**

It must:
- Enable a subsequent planning agent to plan without repeating discovery
- Be grounded in current repo behavior and constraints
- Capture the complete substantive outcome of `grilling`: every user decision, recommendation, fact, investigation finding, evidence limitation, rejected alternative, tradeoff, guardrail, hotspot, caveat, edge case, risk, dependency, and test criterion
- Record every settled grilling decision, recommendation, and rejected alternative with its provenance and rationale
- Record likely touchpoints and possible downstream adaptations

It must **not**:
- Lock exact edit line ranges
- Contain a pseudo-implementation plan
- Promise that implementation can begin without planning
- Turn planning into a formatting-only step
- Contain unresolved options, open questions, or agent-selected design assumptions
- Reduce or omit a substantive grilling result because it appears incidental or does not fit a preferred section

The payload is a complete organized record of `grilling`'s substantive results, not a raw conversation transcript. Omit only mechanical conversation chronology, repeated question wording, and agent-runtime metadata after preserving the result each produced.

## Workflow Steps

### Step 0: Ensure Required `grilling` Dependency

`grilling` is required before this workflow proceeds. Its approved source is:

`https://github.com/mattpocock/skills/tree/main/skills/productivity/grilling`

1. Check whether the `grilling` skill is available.
2. If it is absent, invoke `skill-installer` to install the exact source URL above. Do not use a marketplace substitute, copy its contents into this skill, or fall back to another interviewing process. Tell the user that installation is available only in a new turn/session, then stop. Resume Step 0 only after `grilling` is available.
3. If `grilling` is already available, continue to Step 1.

---

### Step 1: Triage the Request, References, and Context

Before persistence, identify:
- The requested outcome and missing material intent
- Each supplied reference and its proposed light or hard role
- Additional documentation, contracts, or repository surfaces relevant to the request
- The next blocking clarification or reference-authority confirmation

For triage, load relevant repository documents, starting with `AGENTS.md` and `README.md`, then load any other document necessary to understand the request. Do not use a blanket documentation glob. Do not inspect or use a reference as evidence before its role is confirmed. Retain only triage findings that affect the eventual planning specification; do not record the triage process.

---

### Step 2: Run `grilling`

`grilling` was verified during Step 0. Load and follow it directly. Give it the user request, Step 1 triage result, and each proposed reference role. It owns all interview behavior, the questions it asks, fact prerequisites, subagent assignments, recommendations, and its shared-understanding completion gate.

Do not use a supplied reference as evidence until its proposed role is confirmed during the grilling conversation. Do not impose subagent caps or a competing interview loop.

Pass this evidence-collector contract to `grilling`:

| Fact needed | Model | Collector returns |
| --- | --- | --- |
| Source, repository, or documentation meaning | `gpt-5.6-terra` | Evidence, locations, and limitations |
| Inventory or mechanical extraction | `gpt-5.6-luna` | Facts, enumeration, and locations |

Collectors gather evidence only; they do not make user decisions. Do not persist research during the grilling session. If it is interrupted, resume its design tree and unsettled frontier; do not create a clarification file. After `grilling` reaches shared understanding and the user confirms it, record the settled outcome and continue to Step 3.

---

### Step 3: Assemble Candidate Research Content

Only begin this step after `grilling` has reached shared understanding and no known material decision remains unresolved.

Write for a subsequent planning agent, not as an audit of this workflow. The candidate must be complete and self-contained enough for that agent to plan without further research. Transfer **every substantive result from `grilling`** into the appropriate Z01 section: every decision, recommendation, fact, source finding, evidence gap or limitation, rejected alternative and rationale, tradeoff, guardrail, hotspot, caveat, edge case, risk, dependency, and acceptance condition. Do not summarize away, selectively omit, or defer any such result. Omit only mechanical conversation chronology, repeated question wording, and agent-runtime metadata after preserving the result each produced.

Assemble the complete candidate research content in the current response context. Do not create or update a local file or GitHub issue yet; persistence happens only after the Step 4 check passes and the user chooses a destination in Step 5.

**Prepare the local destination metadata:**
- Check for existing Z01 files
- Common locations: `docs/ai/ongoing`, `.ai/ongoing`, `docs/ongoing`
- Use default `docs/ai/ongoing` if none is found; create it only when the user chooses local persistence

**Save ONGOING_DIR location** for Step 5 if local persistence is selected.

**Local file candidate**: `{ONGOING_DIR}/Z01_{feature}_research.md`

**GitHub issue candidate**: `[Idea] <display feature name>`

Keep a concise human-readable display feature name for the GitHub issue title.

**Sanitize the local feature slug:**
- Use snake_case: lowercase with underscores
- Replace spaces and special chars with underscores
- Remove quotes, slashes, colons
- Truncate to 50 characters
- Example: `OAuth 2.0 Authentication!` → `oauth_2_0_authentication`

**Structure**:

```markdown
# {Feature} Research

## Goal and Success
- The problem, intended users, intended outcome, and success measures

## Scope and Non-Goals
- Included work, explicit exclusions, deferred boundaries, and accepted limitations

## Required Behavior
- Required user-visible and system-visible behavior, including critical flows
- Behavior explicitly ruled out

## Material Decisions and Constraints
- Every settled grilling decision that constrains planning
- Every grilling recommendation, rejected alternative, tradeoff, and rationale
- Provenance for each decision and result: user-specified or repository-determined
- Binding reference treatment and source rules, only where they affect the specification

## Existing Context That Matters
- Relevant current behavior, contracts, data, integrations, repository patterns, and likely touchpoints
- Constraints or limitations already present in the repository
- Every repository, source, or evidence-collector finding from grilling, including negative findings

## Planning Guardrails, Hotspots, and Caveats
- Guardrails and patterns that planning must preserve
- Hotspots, integration risks, dependencies, or downstream adaptations needing deliberate treatment
- Caveats, evidence limitations, and accepted tradeoffs that affect the plan

## Edge Cases and Failure Behavior
- Important edge cases, failure behavior, and fallback behavior

## Acceptance Criteria
- What must be true for the feature to be correct, including critical regression coverage and user-visible criteria

## Source Notes
- Complete source and evidence record from grilling: authority, findings, inaccessible areas, contradictions, and limitations
```

**Self-contained requirement (MANDATORY):**
- The selected canonical research source must stand on its own for planning.
- A subsequent planning agent must not need to repeat discovery to understand any substantive grilling result: required behavior, decisions, recommendations, rejected alternatives, evidence, constraints, guardrails, hotspots, caveats, risks, or acceptance criteria.
- Do not require readers to open idea/spec/PRD/ticket documents for core requirements.
- If external docs are mentioned, summarize or copy the relevant requirements into the research payload.
- Phrases like `see spec`, `refer to ticket`, or `details in doc X` are only allowed for optional background, never for required planning inputs.

---

### Step 4: Verify the Complete Research Payload

Check that the candidate is a complete planning input, then remove boundary violations before persisting it.

Move or remove anything that looks like:
- exact implementation task breakdown
- phased PR execution plan
- code-level execution instructions
- hard requirements for exact edit line ranges
- claims that planning has no meaningful decisions left
- unresolved options, questions, bifurcations, or assumptions
- material decisions without user-specified or repository-determined provenance
- an unconfirmed material interpretation
- a hard reference that lacks a synthesized source baseline or whose unverified areas could affect the specification

Research is **NOT complete** while a known meaningful bifurcation remains unresolved. Keep the research workflow in progress, return to the live Step 2 grilling design tree, and do not create or hand off a local Z01 or GitHub `[Idea]` issue.

- If a material intent decision or assumption remains unresolved, return to Step 2.

**Only mark research complete when:**
1. Every material decision is user-specified or repository-determined
2. The payload contains no unresolved options, questions, or agent-selected design assumptions
3. A subsequent planning agent can plan from the payload without further research
4. Every substantive grilling result is recorded: decisions, recommendations, facts, findings, evidence limitations, rejected alternatives, tradeoffs, guardrails, hotspots, caveats, risks, and acceptance conditions
5. The payload stays on the research side of the research/planning boundary
6. Every supplied reference has confirmed authority, and hard-reference evidence is synthesized without inventing missing behavior

Only after all six checks pass, continue to Step 5. Persistence is not an input to this gate.

---

### Step 5: Choose and Persist the Research Destination

After Step 4 passes, honor a destination the user already explicitly selected. Otherwise, offer exactly these choices:
- `Local Z01 file`
- `GitHub [Idea] issue`

The choices are alternative canonical research sources. Do not write both unless the user makes a separate explicit request after this workflow completes.

#### Local Z01 file

If the user chooses local persistence:
1. Create `ONGOING_DIR` if needed.
2. Write the validated payload to `{ONGOING_DIR}/Z01_{feature}_research.md`.
3. Reread the file and verify that the persisted content matches the validated payload.
4. Treat the local file as the canonical planning input.

#### GitHub `[Idea]` issue

If the user chooses GitHub persistence:
1. Resolve the target repository. Default to the current repository unless the user explicitly names another repository.
2. Build a preview containing the resolved repository, the exact title `[Idea] <display feature name>`, and the complete issue body.
3. Use the validated research payload as the complete issue body. The issue must satisfy the same structure, self-containment, provenance, and completeness contract as a local Z01.
4. Show the preview and request explicit approval before creating the issue. Do not treat the earlier destination choice as publication approval.
5. After approval, create the issue, reread the published title and body, and verify them against the preview.
6. Treat the published issue URL or owner/repository plus issue number as the canonical planning input. Do not create a local Z01.

If the target is unresolved, the preview is not approved, publication fails, or published content does not match the approved preview, keep research incomplete and do not hand off to planning.

## Failure Checks

Stop and correct course if you:

- bypassed Step 0, triage, or a triage-driven document need;
- overrode `grilling`, asked the user for a discoverable fact, or treated an unresolved fact as settled;
- adopted a material requirement without user or repository provenance, including unconfirmed reference authority;
- accepted unverified evidence or silently selected among credible alternatives;
- presented a requirement as established without supporting prompt, user, or collected evidence;
- persisted or handed off while decisions, assumptions, provenance, risks, or acceptance criteria remained incomplete; or
- violated the selected canonical-destination contract, including GitHub preview and publication approval.

## Guardrails Against Rationalizing

- A detailed prompt, confidence, convention, or a repository pattern does not authorize an open decision.
- A light reference is inspiration until the user adopts a specific idea; a hard reference still needs verified evidence.
- Grilling asks the entire unblocked frontier. Do not replace it with a single-question loop or a clarification file.
- Planning cannot resolve research ambiguity, and a saved file or issue does not make research complete.

## When to Use

Use when:
- You have a rough idea, partial spec, or well-defined feature request
- You need one entry point that can refine intent and then ground the work in the repo
- You need to surface integration risks, edge cases, constraints, and test criteria before planning
- You want a relentless, evidence-led interview before research is persisted locally or as a GitHub `[Idea]` issue

**Don't use when:**
- The change is trivial enough that no research artifact is needed
- The work is already fully planned and ready for execution

## Handoff to Planning

If any meaningful bifurcation is unresolved:
1. Keep the live research conversation and progress plan open.
2. Do not persist research or hand off to planning.

When all known meaningful bifurcations are resolved and Step 5 verifies the selected destination:
1. For local persistence, announce: `Research complete. Z01_{feature}_research.md ready for planning.`
2. For GitHub persistence, announce: `Research complete. [Idea] issue <issue reference> ready for planning.`
3. Then proceed to planning workflow

**What planning receives:**
- The canonical local Z01 path or GitHub `[Idea]` issue reference
- Patterns that MUST be preserved
- Grounded feature behavior and explicit non-goals
- Current repo state and likely touchpoints
- Planning guardrails, hotspots, caveats, edge cases, failure modes, and compatibility risks
- Test and acceptance criteria
- Resolved material decisions with user or repository provenance
