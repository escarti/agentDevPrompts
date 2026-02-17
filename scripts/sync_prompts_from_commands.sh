#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
COMMANDS_DIR="$ROOT_DIR/commands"
PROMPTS_DIR="$ROOT_DIR/prompts"

mkdir -p "$PROMPTS_DIR"

for f in "$COMMANDS_DIR"/*.md; do
  [ -e "$f" ] || continue
  base="$(basename "$f")"
  ln -sfn "../commands/$base" "$PROMPTS_DIR/$base"
done

for p in "$PROMPTS_DIR"/*.md; do
  [ -e "$p" ] || continue
  base="$(basename "$p")"
  if [ ! -e "$COMMANDS_DIR/$base" ]; then
    rm -f "$p"
  fi
done

echo "Prompts symlinked from commands into: $PROMPTS_DIR"
