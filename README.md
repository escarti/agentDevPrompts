## Install scripts

This folder contains two small helper scripts used when this repository is included as a `.prompt` collection or when you want to install the prompt files into VS Code's User prompts folder.

Files
- `install.sh` — When this repo is copied into another repository as a `/.prompt` folder, running this script will ensure the parent repository's `.gitignore` contains an entry to ignore `/.prompt`.
- `install_copilot_prompts.sh` — Installs any `*.prompt.md` files found in this repo into the VS Code "User/prompts" folder (supports macOS, Linux and common Windows environments).

Quick notes
- Both scripts are written for bash and use common utilities (`find`, `cp`, `ln`, `mkdir`, etc.).
- Run them from this folder (or provide an explicit path). They already try to detect sensible defaults for your platform.

install.sh — purpose and usage
- Purpose: Add `/.prompt` to the parent repository's `.gitignore` when you copy this repo into that parent as `/.prompt`.

Usage
```bash
# from inside the copied `.prompt` folder
./install.sh
```

Behavior
- If the parent repo has no `.gitignore`, it will be created.
- If an entry ignoring `.prompt` already exists, the script does nothing.

install_copilot_prompts.sh — purpose and usage
- Purpose: Install or symlink `*.prompt.md` files into VS Code's User prompts directory so they become available as Copilot/VS Code prompts.

Options
- `-t, --target DIR` — explicit target directory to install into
- `-s, --symlink` — create symlinks instead of copying files
- `-f, --force` — overwrite existing files without backup
- `-y, --yes` — assume yes to prompts (non-interactive)
- `-n, --dry-run` — show actions without modifying files
- `-h, --help` — show help

Examples
```bash
# Dry-run to see where files would go
./install_copilot_prompts.sh --dry-run

# Install by copying into the detected VS Code User prompts folder
./install_copilot_prompts.sh

# Install using a custom target and create symlinks
./install_copilot_prompts.sh -t "$HOME/Library/Application Support/Code/User/prompts" -s

# Force overwrite without prompting
./install_copilot_prompts.sh -f -y
```

Common default target locations
- macOS: `$HOME/Library/Application Support/Code/User/prompts`
- Linux: `$HOME/.config/Code/User/prompts` (or `$XDG_CONFIG_HOME/Code/User/prompts`)
- Windows (Git Bash / WSL): `$APPDATA/Code/User/prompts` or equivalent

Safety
- By default the installer will back up existing files it would overwrite (it renames existing files to `file.bak.TIMESTAMP`) unless `--force` is used.

If you want me to add a small wrapper or a launch task for VS Code to run these from the editor, I can add that next.

---
Generated on: 2025-10-01
