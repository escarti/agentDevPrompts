#!/usr/bin/env bash
set -euo pipefail

# install.sh
# When this repository is copied into another repo as a `.prompt` folder,
# running this script will ensure that `/.prompt` is added to the parent
# repository's `.gitignore` (if not already present).

timestamp() {
  date -u +"%Y-%m-%dT%H:%M:%SZ"
}

# Determine script directory (works for bash; falls back to $0)
script_path="${BASH_SOURCE[0]:-$0}"
script_dir="$(cd "$(dirname "$script_path")" >/dev/null 2>&1 && pwd -P)"

parent_dir="$(dirname "$script_dir")"
gitignore="$parent_dir/.gitignore"

echo "[.prompt] installer: target parent dir -> $parent_dir"

if [ ! -e "$gitignore" ]; then
  echo "[.prompt] .gitignore not found in parent repo. Creating $gitignore"
  printf "# .gitignore created by .prompt/install.sh on %s\n" "$(timestamp)" > "$gitignore"
fi

# Check if .prompt is already ignored. Accepts lines like '.prompt', '/.prompt', '.prompt/' or '/.prompt/'
if grep -Eq '^/?\.prompt(/)?$' "$gitignore"; then
  echo "[.prompt] parent .gitignore already ignores .prompt. No changes made."
  exit 0
fi

printf "\n# Ignore local .prompt folder (added by .prompt/install.sh on %s)\n/.prompt\n" "$(timestamp)" >> "$gitignore"
echo "[.prompt] Added '/.prompt' to $gitignore"

exit 0
