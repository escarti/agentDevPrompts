#!/usr/bin/env bash
set -euo pipefail

# Resolve the real path to this script, following any symlinks
resolve_source() {
  local source_path="$1"
  while [[ -h "$source_path" ]]; do
    local dir
    dir="$(cd -P "$(dirname "$source_path")" && pwd)"
    source_path="$(readlink "$source_path")"
    [[ $source_path != /* ]] && source_path="$dir/$source_path"
  done
  echo "$(cd -P "$(dirname "$source_path")" && pwd)"
}

SOURCE_DIR="$(resolve_source "${BASH_SOURCE[0]:-$0}")"

# Directory where the symlinks will be created (current working directory)
TARGET_DIR="$(pwd -P)"
PROMPTS_DIR="$TARGET_DIR/.prompts"
GITIGNORE_FILE="$TARGET_DIR/.gitignore"

mkdir -p "$PROMPTS_DIR"

shopt -s nullglob
PROMPT_FILES=("$SOURCE_DIR"/A[0-9][0-9]_*.prompt.md)
shopt -u nullglob

if (( ${#PROMPT_FILES[@]} == 0 )); then
  echo "No A** prompt files found in $SOURCE_DIR" >&2
  exit 1
fi

for prompt_file in "${PROMPT_FILES[@]}"; do
  file_name="$(basename "$prompt_file")"
  ln -sfn "$prompt_file" "$PROMPTS_DIR/$file_name"
  echo "Linked $file_name"
done

echo "Symlinks created in $PROMPTS_DIR"

if [[ ! -f "$GITIGNORE_FILE" ]]; then
  touch "$GITIGNORE_FILE"
fi

if ! grep -Fxq ".prompts/*" "$GITIGNORE_FILE"; then
  if [[ -s "$GITIGNORE_FILE" && $(tail -c1 "$GITIGNORE_FILE" 2>/dev/null) != $'\n' ]]; then
    echo >> "$GITIGNORE_FILE"
  fi
  echo ".prompts/*" >> "$GITIGNORE_FILE"
  echo "Added .prompts/* to $(basename "$GITIGNORE_FILE")"
else
  echo ".prompts/* already present in $(basename "$GITIGNORE_FILE")"
fi
