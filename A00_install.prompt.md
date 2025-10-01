<!--
Prompt file: A02_install_prompt.md
Purpose: Provide a Copilot-friendly prompt that describes the action of adding '/.prompt' to a parent repo's .gitignore
-->

# Add /.prompt to parent repository .gitignore

Goal
- Ensure the parent repository (the repo that contains this `.prompt` folder) ignores the `.prompt` directory by adding `/.prompt` to the parent's `.gitignore`.

Context
- This prompt corresponds to a small install script shipped inside a `.prompt` folder. The `.prompt` folder will be copied into other repositories. We want a Copilot-style prompt the assistant can follow to perform the same action as the script.

Constraints and rules
- Be idempotent: do not add duplicate lines to the `.gitignore`.
- If the parent repo has no `.gitignore`, create one.
- Treat these lines as acceptable indicators that `.prompt` is ignored: `.prompt`, `/.prompt`, `.prompt/`, `/.prompt/` (any of those single-line entries means do nothing).
- Prefer writing `/.prompt` (leading slash) when appending to `.gitignore` so the intent is explicit.
- Do not commit changes automatically. Output the proposed diff or the changed file and ask the user whether to commit.
- If the parent directory does not appear to be a Git repository, warn and ask how to proceed. Optionally offer to write to `.git/info/exclude` instead (local-only ignore) if the user prefers.

Task (steps to perform)
1. Resolve the absolute path of the parent directory (the directory that contains this prompt folder).
2. Locate the parent `.gitignore` at `<parent>/.gitignore`.
3. If `<parent>/.gitignore` does not exist, create it with a short comment header containing a timestamp.
4. Check for any existing line that exactly matches any of: `.prompt`, `/.prompt`, `.prompt/`, `/.prompt/`. If any of those lines exist, exit with message "already ignored" and do nothing.
5. Otherwise, append a timestamped comment and the line `/.prompt` to the end of `<parent>/.gitignore`.
6. Show the diff or the updated content to the user and ask whether to `git add` and `git commit` and `git push`.

Example of the install script (reference)
```bash
#!/usr/bin/env bash
set -euo pipefail

timestamp() { date -u +"%Y-%m-%dT%H:%M:%SZ"; }
script_path="${BASH_SOURCE[0]:-$0}"
script_dir="$(cd "$(dirname "$script_path")" >/dev/null 2>&1 && pwd -P)"
parent_dir="$(dirname "$script_dir")"
gitignore="$parent_dir/.gitignore"

if [ ! -e "$gitignore" ]; then
  printf "# .gitignore created by .prompt/install.sh on %s\n" "$(timestamp)" > "$gitignore"
fi

if grep -Eq '^/?\.prompt(/)?$' "$gitignore"; then
  echo "parent .gitignore already ignores .prompt"
  exit 0
fi

printf "\n# Ignore local .prompt folder (added by .prompt/install.sh on %s)\n/.prompt\n" "$(timestamp)" >> "$gitignore"
echo "Added '/.prompt' to $gitignore"
```

Assistant behavior guidance (for Copilot/assistant)
- When asked to perform this task, describe the exact file changes you will make. Prefer showing a unified diff and the new file contents.
- Ask the user for confirmation before committing or pushing.
- Offer a `--local` alternative that writes to `<parent>/.git/info/exclude` (this will not be committed and is local-only). If the user requests `--local`, prefer that.
- Offer a `--dry-run` option that prints the actions without changing files.

Example prompts you can give to the assistant
- "Add /.prompt to parent .gitignore (dry-run)"
- "Add /.prompt to parent .gitignore and commit with message 'Ignore .prompt folder'"
- "Add /.prompt to parent .git/info/exclude instead"

Acceptance criteria
- The parent `.gitignore` contains a line `/.prompt` or one of the accepted variants.
- No duplicate entries are added.
- The assistant presents the proposed change and waits for confirmation before committing.
