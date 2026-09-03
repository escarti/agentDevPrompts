#!/usr/bin/env bash

set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT_DIR"

failures=0

fail() {
  printf 'FAIL: %s\n' "$1" >&2
  failures=$((failures + 1))
}

check_mapping() {
  local skill_path="$1"
  local expected="$2"
  local actual

  actual="$(rg -o 'superpowers:[a-z-]+' "$skill_path" | sort -u | paste -sd ' ' - || true)"
  if [[ "$actual" != "$expected" ]]; then
    fail "$skill_path must reference only: ${expected:-no Superpowers skills} (found: ${actual:-none})"
  fi
}

active_paths=(AGENTS.md CLAUDE.md README.md PUBLISHING.md commands prompts skills)
if rg -n 'load-superpowers|using-superpowers' "${active_paths[@]}" >/dev/null; then
  fail 'Remove obsolete Superpowers bootstrap references from active repository guidance.'
fi

if [[ -e skills/load-superpowers ]]; then
  fail 'Remove the obsolete skills/load-superpowers directory.'
fi

check_mapping skills/feature-researching/SKILL.md 'superpowers:brainstorming'
check_mapping skills/feature-planning/SKILL.md 'superpowers:writing-plans'
check_mapping skills/feature-implementing/SKILL.md 'superpowers:executing-plans superpowers:subagent-driven-development'
check_mapping skills/feature-pr-fixing/SKILL.md 'superpowers:systematic-debugging'
check_mapping skills/fixing-small-issues/SKILL.md 'superpowers:systematic-debugging superpowers:test-driven-development superpowers:verification-before-completion'
check_mapping skills/feature-qa-review/SKILL.md ''
check_mapping skills/feature-pr-reviewing/SKILL.md ''
check_mapping skills/feature-finishing/SKILL.md ''
check_mapping skills/feature-documenting/SKILL.md ''

for command_path in commands/*.md; do
  command_name="$(basename "$command_path")"
  prompt_path="prompts/$command_name"

  if [[ ! -L "$prompt_path" ]]; then
    fail "$prompt_path must be a symlink for $command_path."
    continue
  fi

  if [[ "$(readlink "$prompt_path")" != "../commands/$command_name" ]]; then
    fail "$prompt_path must target ../commands/$command_name."
  fi
done

for prompt_path in prompts/*.md; do
  prompt_name="$(basename "$prompt_path")"
  if [[ ! -e "commands/$prompt_name" ]]; then
    fail "$prompt_path has no matching command file."
  fi
done

for manifest in .claude-plugin/plugin.json .claude-plugin/marketplace.json; do
  if ! python3 -m json.tool "$manifest" >/dev/null; then
    fail "$manifest must contain valid JSON."
  fi
done

if (( failures > 0 )); then
  printf 'Skill dependency validation failed with %d issue(s).\n' "$failures" >&2
  exit 1
fi

printf 'Skill dependency validation passed.\n'
