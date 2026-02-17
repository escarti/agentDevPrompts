---
name: use-sub-agent
description: Use when work should be delegated to one or more headless Codex subagents in the same machine session, especially for parallelizable tasks and when reliable launch, timeout, and log-handling behavior is required.
---

# use-sub-agent

## YOU ARE READING THIS SKILL RIGHT NOW

**STOP. Before doing ANYTHING else:**

1. ☐ Create TodoWrite checklist (see below)
2. ☐ Mark Step 1 as `in_progress`
3. ☐ Decide single vs parallel subagent plan

**If you launched any subagent before creating TodoWrite, you FAILED.**

## MANDATORY FIRST ACTION: Create TodoWrite

```typescript
TodoWrite({
  todos: [
    {content: "Step 1: Identify delegation scope and choose single or parallel subagents", status: "in_progress", activeForm: "Planning delegation"},
    {content: "Step 2: Draft subagent prompts with safe shell escaping", status: "pending", activeForm: "Drafting prompts"},
    {content: "Step 3: Launch each subagent with codex --yolo exec and 30-minute timeout wrapper", status: "pending", activeForm: "Launching subagents"},
    {content: "Step 4: Wait for completion and capture per-subagent exit status", status: "pending", activeForm: "Collecting statuses"},
    {content: "Step 5: Inspect each subagent log before declaring success", status: "pending", activeForm: "Reviewing logs"},
    {content: "Step 6: Merge successful outputs and rerun failed/incomplete tasks", status: "pending", activeForm: "Merging outputs"},
    {content: "Step 7: Report final synthesized result with completion evidence", status: "pending", activeForm: "Reporting result"}
  ]
})
```

After each step: mark completed and move `in_progress` to the next step.

## Overview
Delegate independent work to headless Codex subprocesses with predictable launch, timeout, and result collection.

## Rules
1. Launch each subagent with `codex --yolo exec "..."`.
2. Escape shell-sensitive prompt content. Never pass unescaped backticks or `$()`.
3. When running subagents from a shell tool call, set wrapper timeout to 30 minutes (`timeout_ms: 1800000`) per run.
4. For parallel runs, use background jobs and `wait`, then inspect each log before declaring success.
5. Assume subagents inherit CLI defaults (approval, sandbox, model behavior). Keep prompts focused and lightweight.

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
3. Merge outputs only from completed runs. Rerun incomplete runs with narrower prompts.

## Common Mistakes
| Mistake | Fix |
|---|---|
| Using plain shell commands and calling them subagents | Use `codex --yolo exec` for each subagent |
| Missing timeout override | Set `timeout_ms: 1800000` for shell tool calls that run subagents |
| Trusting wrapper exit code alone | Always inspect each subagent log |
| Overloading prompts with too much context | Split work and keep each prompt narrow |
