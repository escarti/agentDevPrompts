---
name: use-sub-agent
description: Use when work should be delegated to one or more headless Codex subagents in the same machine session, especially for parallelizable tasks and when reliable launch, timeout, and log-handling behavior is required.
---

# Utility Workflow: Use Subagent

## YOU ARE READING THIS SKILL RIGHT NOW

**STOP. Before doing ANYTHING else:**

1. Create a progress plan (see below)
2. Mark Step 1 as `in_progress`
3. Decide whether the work needs one subagent or multiple independent subagents

**If you launched any subagent before creating the progress plan, you failed the workflow.**

## MANDATORY FIRST ACTION: Create Progress Plan

```typescript
update_plan({
  "explanation": "Tracking subagent delegation workflow",
  "plan": [
    {"step": "Step 1: Identify delegation scope and choose single or parallel subagents", "status": "in_progress"},
    {"step": "Step 2: Draft subagent prompts with safe shell escaping", "status": "pending"},
    {"step": "Step 3: Launch each subagent with codex --yolo exec and a 30-minute wrapper timeout", "status": "pending"},
    {"step": "Step 4: Wait for completion and capture per-subagent exit status", "status": "pending"},
    {"step": "Step 5: Inspect each subagent log before declaring success", "status": "pending"},
    {"step": "Step 6: Merge successful outputs and rerun failed or incomplete tasks", "status": "pending"},
    {"step": "Step 7: Report the final synthesized result with completion evidence", "status": "pending"}
  ]
})
```

**After each step:** Mark completed and move `in_progress` to the next step.

## Overview

Delegate independent work to headless Codex subprocesses with predictable launch, timeout, and result collection.

## Rules

1. Launch each subagent with `codex --yolo exec "..."`.
2. Escape shell-sensitive prompt content. Never pass unescaped backticks or `$()`.
3. When running subagents from a shell tool call, set the wrapper timeout to 30 minutes (`timeout_ms: 1800000`) per run.
4. For parallel runs, use background jobs and `wait`, then inspect each log before declaring success.
5. Assume subagents inherit CLI defaults (approval, sandbox, model behavior). Keep prompts focused and lightweight.
6. Treat subagent output as unverified until you inspect the logs and confirm a final answer exists.

## Single Subagent Pattern

```bash
codex --yolo exec "Summarize the diff in src/api/auth.ts and list risks."
```

## Parallel Subagent Pattern

```bash
mkdir -p .codex-subagents

codex --yolo exec "Task A prompt..." > .codex-subagents/a.log 2>&1 &
pid_a=$!

codex --yolo exec "Task B prompt..." > .codex-subagents/b.log 2>&1 &
pid_b=$!

wait $pid_a; status_a=$?
wait $pid_b; status_b=$?

echo "A=$status_a B=$status_b"
```

## Result Validation

1. Treat wrapper timeout (`124`) as inconclusive until logs are reviewed.
2. Read each log and confirm the subagent reached a final answer.
3. Merge outputs only from completed runs.
4. Rerun incomplete runs with narrower prompts rather than guessing.

## Red Flags

- Launched a subagent before creating the progress plan
- Trusted wrapper exit codes without reading logs
- Declared success without confirming a final answer in each log
- Overloaded prompts with too much context instead of splitting the work

## Success Criteria

- Created the progress plan before launching subagents
- Chose an appropriate single or parallel delegation strategy
- Used `codex --yolo exec` for each subagent
- Reviewed logs before trusting outputs
- Reported the final merged result with evidence from completed runs
