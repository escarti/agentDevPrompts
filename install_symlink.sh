#!/usr/bin/env bash
set -euo pipefail

script_path="${BASH_SOURCE[0]:-$0}"
script_dir="$(cd "$(dirname "$script_path")" >/dev/null 2>&1 && pwd -P)"
source_script="$script_dir/create_symlink_prompt.sh"

if [[ ! -x "$source_script" ]]; then
  echo "Missing or non-executable source script: $source_script" >&2
  exit 1
fi

bin_dir="$HOME/.local/bin"
install_name="add_prompts"
target_link="$bin_dir/$install_name"

mkdir -p "$bin_dir"
ln -sfn "$source_script" "$target_link"
echo "Symlinked $install_name -> $source_script"

shell_name="$(basename "${SHELL:-}")"
profile_candidates=()

if [[ "$shell_name" == "zsh" ]]; then
  profile_candidates+=("${ZDOTDIR:-$HOME}/.zshrc")
  profile_candidates+=("${ZDOTDIR:-$HOME}/.zprofile")
fi

if [[ "$shell_name" == "bash" ]]; then
  profile_candidates+=("$HOME/.bashrc")
  profile_candidates+=("$HOME/.bash_profile")
fi

profile_candidates+=("$HOME/.profile")
profile_file=""

for candidate in "${profile_candidates[@]}"; do
  [[ -z "$candidate" ]] && continue
  if [[ -f "$candidate" ]]; then
    profile_file="$candidate"
    break
  fi
  if [[ -z "$profile_file" ]]; then
    profile_file="$candidate"
  fi
done

if [[ -z "$profile_file" ]]; then
  profile_file="$HOME/.profile"
fi

mkdir -p "$(dirname "$profile_file")"
[[ -f "$profile_file" ]] || touch "$profile_file"

if ! grep -Fq ".local/bin" "$profile_file"; then
  if [[ -s "$profile_file" && $(tail -c1 "$profile_file" 2>/dev/null) != $'\n' ]]; then
    echo >> "$profile_file"
  fi
  {
    echo "# Added by install_symlink.sh on $(date -u +'%Y-%m-%dT%H:%M:%SZ')"
    echo 'export PATH="$HOME/.local/bin:$PATH"'
  } >> "$profile_file"
  echo "Updated PATH in $profile_file"
else
  echo "$profile_file already ensures ~/.local/bin is on PATH"
fi

echo "Installation complete. Restart your shell or source $profile_file to use '$install_name'."
