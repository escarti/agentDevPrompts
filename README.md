## Install scripts

This folder contains helper scripts you can use when working with these prompt files locally or when you copy the repository into another project.

Files
- `install.sh` — Ensures the parent repository's `.gitignore` ignores a copied `/.prompt` folder.
- `install_copilot_prompts.sh` — Installs or symlinks prompt files named like `A01_... .m` (pattern: `A[0-9][0-9]_*.m`) into VS Code's User `prompts` directory.
- `create_symlink_prompt.sh` — Creates a `.prompts` folder in the current working directory with symlinks to the repository prompt files and adds `.prompts/*` to that directory's `.gitignore`.
- `install_symlink.sh` — Adds `create_symlink_prompt.sh` to your shell `PATH` via `~/.local/bin` so you can call it from anywhere by using `add_prompts`

Quick notes
- All scripts target bash-compatible shells and rely on standard utilities (`find`, `cp`, `ln`, `mkdir`, etc.).
- Run them from this folder unless noted; they detect sensible defaults where possible.

install.sh — purpose and usage
- Purpose: Add `/.prompt` to the parent repository's `.gitignore` when you copy this repo into that parent as `/.prompt`.

Usage
```bash
# from inside the copied `.prompt` folder
./install.sh
```

Behavior
- Creates the parent's `.gitignore` if it does not exist.
- Leaves the file untouched when an ignore rule for `.prompt` is already present.

install_copilot_prompts.sh — purpose and usage
- Purpose: Install or symlink prompt files named like `A01_... .m` (pattern: `A[0-9][0-9]_*.m`) into VS Code's User prompts directory so they become available as Copilot/VS Code prompts.

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
- By default the installer backs up files before overwriting them (unless `--force` is used).

create_symlink_prompt.sh — purpose and usage
- Purpose: From any directory, create `.prompts` containing symlinks to the repository prompt files and keep `.prompts/*` out of version control.

Usage
```bash
# from inside a project that should reference these prompts
/absolute/path/to/create_symlink_prompt.sh
```

Behavior
- Resolves the real repository location even when invoked through a symlink.
- Creates or reuses `.prompts`, linking every `A[0-9][0-9]_*.m` prompt file.
- Appends `.prompts/*` to the current directory's `.gitignore` if missing.

install_symlink.sh — purpose and usage
- Purpose: Install a global `create_symlink` command (or the name of your choice) into `~/.local/bin` and ensure that directory is on your `PATH`.

Usage
```bash
./install_symlink.sh
# then restart your shell or source the profile it reports

# call from anywhere
create_symlink   # or rename the symlink after installation if you prefer a different command name
```

Behavior
- Symlinks `create_symlink_prompt.sh` into `~/.local/bin/create_symlink` (you can rename that symlink later to `add_prompts`, etc.).
- Creates the target directory if needed.
- Detects a suitable shell profile (`.zshrc`, `.bashrc`, `.profile`, …) and prepends `~/.local/bin` to `PATH` if not already present.
- Adds a single timestamped comment block when it modifies the profile.

If you want a wrapper or VS Code launch task to run these scripts from the editor, let me know.
