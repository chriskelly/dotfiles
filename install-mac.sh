#!/usr/bin/env bash
set -euo pipefail

# macOS-specific installer
# - Reuses install-portable.sh for core setup
# - Adds macOS-only Zsh configuration (PATHs, nvm, Angular completion, etc.)

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]:-$0}")" && pwd)"

log() {
  printf '%s\n' "[$(basename "$0")] $*"
}

backup_file() {
  local target="$1"
  if [ -e "$target" ] || [ -L "$target" ]; then
    local backup
    backup="${target}.backup-$(date +%Y%m%d-%H%M%S)"
    log "Backing up existing $(basename "$target") to $(basename "$backup")"
    mv "$target" "$backup"
  fi
}

link_file() {
  local src="$1"
  local dest="$2"
  if [ "$(readlink "$dest" 2>/dev/null)" = "$src" ]; then
    return
  fi
  if [ ! -e "$src" ]; then
    log "Error: Source file $src does not exist. Skipping symlink creation for $dest"
    return 1
  fi
  backup_file "$dest"
  ln -s "$src" "$dest"
  log "Linked $dest -> $src"
}

main() {
  if [[ "$OSTYPE" != darwin* ]]; then
    log "This script is intended for macOS (OSTYPE=darwin). Aborting."
    exit 1
  fi

  log "Running portable installer first..."
  bash "$REPO_DIR/install-portable.sh"

  log "Linking macOS-specific Zsh configuration..."
  link_file "$REPO_DIR/config/zsh/.zshrc.mac" "$HOME/.zshrc.mac"

  cat <<'EOF'
[install-mac.sh] macOS-specific configuration linked.

Heavy tools such as Flutter, Android SDK, and nvm are NOT auto-installed.
This config will enable them if you install them yourself:
  - Flutter:   follow the official docs, then ensure /Applications/flutter exists.
  - Android:   install Android Studio / command line tools so ~/Library/Android/sdk exists.
  - nvm:       brew install nvm && follow its setup instructions.

After installing any of these tools, start a new shell or run "exec zsh"
so the PATH and completions take effect.
EOF
}

main "$@"

