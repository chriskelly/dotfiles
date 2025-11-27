# Personal Zsh dotfiles

This repo stores a minimal, portable Zsh setup that you understand and can
reuse across environments (devcontainers, SSH sessions, and macOS).

## Layout

- `config/zsh/.zshrc`: portable interactive Zsh config.
- `config/zsh/.zshenv`: placeholder for environment-only variables (currently minimal).
- `config/zsh/.zsh_plugins.txt`: Antidote plugin list (source of truth).
- `config/zsh/.zsh_plugins.zsh`: Antidote-generated plugin bundle (checked in as a fallback).
- `config/zsh/.zshrc.mac`: macOS-specific additions (Flutter, Android SDK, Ruby, nvm, Angular).
- `install-portable.sh`: portable installer for Zsh + Oh My Zsh + Antidote + symlinks.
- `install-mac.sh`: macOS installer that reuses the portable installer and adds mac-only config.

## install-portable.sh

Use this in devcontainers, remote SSH sessions, and on macOS when you just want
your core Zsh experience:

```bash
cd ~/dotfiles
./install-portable.sh
```

What it does:

- Best-effort ensures `zsh`, `git`, and `curl` are installed on:
  - macOS (Homebrew)
  - Debian/Ubuntu (apt)
- Installs **Oh My Zsh** non-interactively with `RUNZSH=no` and `KEEP_ZSHRC=yes`.
- Installs **Antidote** into `$HOME/.antidote` via `git clone`.
- Symlinks these files into your `$HOME`:
  - `~/.zshrc`
  - `~/.zshenv`
  - `~/.zsh_plugins.txt`
  - `~/.zsh_plugins.zsh`
- Backs up any existing files as `.<name>.backup-YYYYMMDD-HHMMSS`.

It does **not** install heavy language runtimes or SDKs.

## install-mac.sh

Use this on macOS for your full setup:

```bash
cd ~/dotfiles
./install-mac.sh
```

What it does:

- Verifies it is running on macOS.
- Runs `install-portable.sh` first (to avoid duplicated logic).
- Symlinks `config/zsh/.zshrc.mac` to `~/.zshrc.mac`.
- Keeps heavy tools **manual**:
  - Flutter
  - Android SDK
  - nvm

If those tools are installed in their usual locations, `.zshrc.mac` will:

- Add their `bin` directories to your `PATH`.
- Initialize `nvm` and its completions.
- Enable Angular CLI completion when `ng` is available.

## Antidote and plugins

- Plugins are listed in `config/zsh/.zsh_plugins.txt`.
- On shell startup, Antidote will:
  - Read from `~/.zsh_plugins.txt`.
  - Generate/update `~/.zsh_plugins.zsh` when needed.
  - Source `~/.zsh_plugins.zsh`.

You can edit `config/zsh/.zsh_plugins.txt` to adjust plugins, then re-open your
shell (or run `exec zsh`) to regenerate the bundle.

## Usage notes

- After running an installer, restart your shell or run:

  ```bash
  exec zsh
  ```

- For now, only Zsh-related dotfiles are managed. You can add more later (e.g.
  `gitconfig`, `vimrc`) following the same symlink pattern if you like.


