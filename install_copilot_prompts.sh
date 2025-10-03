#!/usr/bin/env bash
set -euo pipefail

# install_copilot_prompts.sh
# Install  prompt .md files from this repository into the VS Code "User/prompts" folder
# Supports macOS, Linux and Windows (when running under Git Bash / WSL with proper paths)

script_path="${BASH_SOURCE[0]:-$0}"
script_dir="$(cd "$(dirname "$script_path")" >/dev/null 2>&1 && pwd -P)"
repo_root="$script_dir"

timestamp() { date -u +"%Y%m%dT%H%M%SZ"; }

usage() {
  cat <<EOF
Usage: $(basename "$0") [options]

Options:
  -t, --target DIR    Explicit VS Code User prompts target directory
  -f, --force          Overwrite existing files without backup
  -y, --yes            Don't prompt for confirmation when creating target
  -n, --dry-run        Show what would be done and exit
  -h, --help           Show this help

By default the script will try to find a likely VS Code User prompts folder for
your platform (e.g. macOS: ~/Library/Application Support/Code/User/prompts) and
install any prompt *.md files found in this repository into that folder.
EOF
}

DRY_RUN=0
FORCE=0
ASSUME_YES=0
EXPLICIT_TARGET=""

while [[ $# -gt 0 ]]; do
  case "$1" in
    -t|--target) EXPLICIT_TARGET="$2"; shift 2;;
    -f|--force) FORCE=1; shift;;
    -y|--yes) ASSUME_YES=1; shift;;
    -n|--dry-run) DRY_RUN=1; shift;;
    -h|--help) usage; exit 0;;
    --) shift; break;;
    *) echo "Unknown option: $1" >&2; usage; exit 2;;
  esac
done

find_candidates() {
  local candidates=()
  case "$(uname -s)" in
    Darwin)
      candidates+=("$HOME/Library/Application Support/Code/User/prompts")
      candidates+=("$HOME/Library/Application Support/Code - Insiders/User/prompts")
      candidates+=("$HOME/Library/Application Support/VSCodium/User/prompts")
      ;;
    Linux)
      if [[ -n "${XDG_CONFIG_HOME:-}" ]]; then
        candidates+=("$XDG_CONFIG_HOME/Code/User/prompts")
        candidates+=("$XDG_CONFIG_HOME/Code - Insiders/User/prompts")
        candidates+=("$XDG_CONFIG_HOME/VSCodium/User/prompts")
      fi
      candidates+=("$HOME/.config/Code/User/prompts")
      candidates+=("$HOME/.config/Code - Insiders/User/prompts")
      candidates+=("$HOME/.config/VSCodium/User/prompts")
      ;;
    CYGWIN*|MINGW*|MSYS*)
      candidates+=("$APPDATA/Code/User/prompts")
      candidates+=("$APPDATA/Code - Insiders/User/prompts")
      candidates+=("$APPDATA/VSCodium/User/prompts")
      ;;
    *)
      # fallback generic
      candidates+=("$HOME/.config/Code/User/prompts")
      candidates+=("$HOME/Library/Application Support/Code/User/prompts")
      ;;
  esac
  printf "%s\n" "${candidates[@]}"
}

choose_target() {
  if [[ -n "$EXPLICIT_TARGET" ]]; then
    echo "$EXPLICIT_TARGET"
    return
  fi

  local candidates
  # read candidates into an array in a portable way
  candidates=()
  while IFS= read -r line; do
    candidates+=("$line")
  done < <(find_candidates)

  # prefer first existing candidate
  for c in "${candidates[@]}"; do
    if [[ -d "$c" ]]; then
      echo "$c"
      return
    fi
  done

  # none existed, use primary default for platform (first candidate)
  echo "${candidates[0]}"
}

TARGET_DIR="$(choose_target)"

if [[ $DRY_RUN -eq 1 ]]; then
  echo "[dry-run] would install into: $TARGET_DIR"
fi

# Find prompt files in repo root (portable)
PROMPT_FILES=()
# Prefer explicit A##_*.m prompt filenames to avoid matching README.md or other generic .md files
while IFS= read -r -d $'\0' file; do
  PROMPT_FILES+=("$file")
done < <(find "$repo_root" -maxdepth 1 -type f -name "A[0-9][0-9]_*.m" -print0)

# Fallback to A##_*.md (older naming that used .md)
if [[ ${#PROMPT_FILES[@]} -eq 0 ]]; then
  while IFS= read -r -d $'\0' file; do
    PROMPT_FILES+=("$file")
  done < <(find "$repo_root" -maxdepth 1 -type f -name "A[0-9][0-9]_*.md" -print0)
fi

# Final fallback for legacy naming
if [[ ${#PROMPT_FILES[@]} -eq 0 ]]; then
  while IFS= read -r -d $'\0' file; do
    PROMPT_FILES+=("$file")
  done < <(find "$repo_root" -maxdepth 1 -type f -name "*.prompt.md" -print0)
fi

if [[ ${#PROMPT_FILES[@]} -eq 0 ]]; then
  echo "No prompt files (A##_*.m, A##_*.md or *.prompt.md) found in $repo_root" >&2
  exit 1
fi

echo "Found ${#PROMPT_FILES[@]} prompt file(s):"
for f in "${PROMPT_FILES[@]}"; do echo "  - $(basename "$f")"; done

if [[ $DRY_RUN -eq 1 ]]; then
  echo "\n[dry-run] target directory (resolved): $TARGET_DIR"
fi

if [[ $ASSUME_YES -ne 1 && $DRY_RUN -ne 1 ]]; then
  if [[ ! -d "$TARGET_DIR" ]]; then
    echo "Target directory $TARGET_DIR does not exist and will be created. Continue? [y/N]"
    read -r ans
    if [[ ! "$ans" =~ ^[Yy] ]]; then
      echo "Aborted by user."; exit 0
    fi
  fi
fi

if [[ $DRY_RUN -ne 1 ]]; then
  mkdir -p "$TARGET_DIR"
fi

echo "Installing to $TARGET_DIR"

for src in "${PROMPT_FILES[@]}"; do
  base="$(basename "$src")"
  # Derive a stable prompt filename for Copilot: always use the .prompt.md suffix
  # Strip known extensions in order: .prompt.md (legacy), .m, .md
  name_root="$base"
  if [[ "$name_root" == *.prompt.md ]]; then
    name_root="${name_root%.prompt.md}"
  elif [[ "$name_root" == *.m ]]; then
    name_root="${name_root%.m}"
  elif [[ "$name_root" == *.md ]]; then
    name_root="${name_root%.md}"
  fi
  dest_base="${name_root}.prompt.md"
  dest="$TARGET_DIR/$dest_base"

  if [[ -e "$dest" && $FORCE -ne 1 ]]; then
    backup="$dest.bak.$(timestamp)"
    echo "Backing up existing $dest -> $backup"
    if [[ $DRY_RUN -eq 0 ]]; then
      mv "$dest" "$backup"
    fi
  elif [[ -e "$dest" && $FORCE -eq 1 ]]; then
    echo "Overwriting existing $dest (force)"
  fi

  if [[ $DRY_RUN -eq 1 ]]; then
    echo "[dry-run] cp \"$src\" \"$dest\""
  else
    cp -p "$src" "$dest"
    echo "Installed: $dest"
  fi
done

echo "Done."

exit 0
