---
name: feature-researching
description: Use when a feature idea needs a confirmed shared understanding and a research specification before implementation planning
---

# Feature Research

Invoke `grilling` and let it run its interview until it reaches shared understanding and the user confirms it. Do not run a parallel interview or draft the specification while grilling is in progress.

After grilling finishes, write its agreed outcome as one complete, self-contained Z01 specification using the format below. Record grilling decisions and established facts; do not invent decisions or include unresolved options. Do not include specific file paths or code snippets in the specification.

## Research Output Contract

**The persisted research payload is a grounded feature specification.** It must:

- Enable a subsequent planning agent to plan without repeating discovery.
- Be grounded in current repo behavior and constraints.
- Capture the complete substantive outcome of `grilling`: every user decision, recommendation, fact, investigation finding, evidence limitation, rejected alternative, tradeoff, guardrail, hotspot, caveat, edge case, risk, dependency, and test criterion.
- Record every settled grilling decision, recommendation, and rejected alternative with its provenance and rationale.
- Record likely touchpoints and possible downstream adaptations.

It must not lock exact edit line ranges, contain a pseudo-implementation plan, promise that implementation can begin without planning, turn planning into a formatting-only step, or contain unresolved options, open questions, or agent-selected design assumptions. Do not reduce or omit a substantive grilling result because it appears incidental or does not fit a preferred section.

The payload is a complete organized record of `grilling`'s substantive results, not a raw transcript. Omit only mechanical conversation chronology, repeated question wording, and agent-runtime metadata after preserving the result each produced. Follow the `Z01 Format` template below.

## Z01 Format

```markdown
# {Feature} Research

## 1. Problem Statement
Describe the problem from the user's perspective.

## 2. Solution
Describe the intended outcome and success measures.

### Required Behavior
- Required user-visible and system-visible behavior, including critical flows
- Behavior explicitly ruled out
- Acceptance criteria for considering the solution done

## 3. Implementation Decisions
- All decisions reached through grilling
- Modules to build or modify and their affected interfaces
- Technical clarifications, architectural decisions, schema changes, API contracts, and specific interactions

## 4. Planning Guardrails, Hotspots, and Caveats
- Guardrails and patterns planning must preserve
- Hotspots, integration risks, dependencies, and downstream adaptations needing deliberate treatment
- Caveats, evidence limitations, and accepted tradeoffs that affect the plan

## 5. Testing
- What should be tested and how
- Important edge cases, failure behavior, and fallback behavior

## 6. Out of Scope
State explicit exclusions.

## 7. Notes
Record other relevant notes.
```

## Persist the Specification

Honor a destination the user already selected. Otherwise ask them to choose one:

- **Local Z01 file:** `{ONGOING_DIR}/Z01_{feature}_research.md`; use an existing ongoing-artifact directory or default to `docs/ai/ongoing/`. Make the feature slug lowercase `snake_case`, remove quotes and path separators, and limit it to 50 characters.
- **GitHub issue:** `[Idea] <display feature name>` in the current repository unless the user names another.

The local file and GitHub issue are alternative canonical sources. For GitHub, show the resolved repository, title, and complete specification, then get approval before creating the issue. Do not also create a local Z01. After writing either destination, reread it and verify the saved specification matches; for GitHub, verify the title too.

## Handoff

After persistence succeeds, provide the canonical Z01 path or GitHub issue reference for feature planning.
