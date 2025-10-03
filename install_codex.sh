#!/usr/bin/env bash
set -euo pipefail

# Resolve the real path of this script, following symlinks
resolve_source_dir() {
  local source_path="$1"
  while [[ -h "$source_path" ]]; do
    local dir
    dir="$(cd -P "$(dirname "$source_path")" && pwd)"
    source_path="$(readlink "$source_path")"
    [[ $source_path != /* ]] && source_path="$dir/$source_path"
  done
  cd -P "$(dirname "$source_path")" && pwd
}

SCRIPT_DIR="$(resolve_source_dir "${BASH_SOURCE[0]:-$0}")"
TARGET_DIR="$HOME/.codex/prompts"

mkdir -p "$TARGET_DIR"

timestamp() { date -u +"%Y%m%dT%H%M%SZ"; }

shopt -s nullglob
PROMPT_FILES=("$SCRIPT_DIR"/A[0-9][0-9]_*.m)
shopt -u nullglob

# Fallback to .md if no .m files are present
if (( ${#PROMPT_FILES[@]} == 0 )); then
  shopt -s nullglob
  PROMPT_FILES=("$SCRIPT_DIR"/A[0-9][0-9]_*.md)
  shopt -u nullglob
fi

# Final fallback to legacy *.prompt.md
if (( ${#PROMPT_FILES[@]} == 0 )); then
  shopt -s nullglob
  PROMPT_FILES=("$SCRIPT_DIR"/*.prompt.md)
  shopt -u nullglob
fi

if (( ${#PROMPT_FILES[@]} == 0 )); then
  echo "No A** prompt files found in $SCRIPT_DIR" >&2
  exit 1
fi

for prompt_file in "${PROMPT_FILES[@]}"; do
  file_name="$(basename "$prompt_file")"
  dest="$TARGET_DIR/$file_name"

  if [[ -e "$dest" ]]; then
    backup="$dest.bak.$(timestamp)"
    mv -- "$dest" "$backup"
    echo "Backed up existing $dest -> $(basename "$backup")"
  fi

  # Copy the prompt file into the Codex prompts directory (don't use symlinks)
  cp -p -- "$prompt_file" "$dest"
  echo "Copied $file_name"
done

echo "Prompt files copied into $TARGET_DIR"
