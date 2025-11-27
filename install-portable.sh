#!/usr/bin/env bash
set -euo pipefail

# Portable Zsh + Oh My Zsh + Antidote installer
# - Intended for devcontainers, SSH sessions, and macOS
# - Best-effort installation of dependencies on common platforms

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]:-$0}")" && pwd)"

have() {
  command -v "$1" >/dev/null 2>&1
}

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
  backup_file "$dest"
  ln -s "$src" "$dest"
  log "Linked $dest -> $src"
}

detect_pkg_manager() {
  if have brew; then
    echo "brew"
  elif have apt-get; then
    echo "apt"
  else
    echo "none"
  fi
}

install_pkg() {
  local pkg="$1"
  local pm
  pm="$(detect_pkg_manager)"

  case "$pm" in
    brew)
      log "Installing $pkg with Homebrew (best-effort)..."
      brew install "$pkg" || log "Warning: brew install $pkg failed; please install it manually."
      ;;
    apt)
      log "Installing $pkg with apt (best-effort)..."
      if have sudo; then
        if ! (sudo apt-get update -y && sudo apt-get install -y "$pkg"); then
          log "Warning: apt-get install $pkg failed; please install it manually."
        fi
      else
        if ! (apt-get update -y && apt-get install -y "$pkg"); then
          log "Warning: apt-get install $pkg failed; please install it manually."
        fi
      fi
      ;;
    *)
      log "No supported package manager found for auto-installing $pkg. Please install it manually."
      ;;
  esac
}

ensure_core_tools() {
  for bin in zsh git curl; do
    if ! have "$bin"; then
      log "$bin not found; attempting best-effort installation."
      install_pkg "$bin"
    fi
  done
}

install_oh_my_zsh() {
  if [ -d "$HOME/.oh-my-zsh" ]; then
    log "Oh My Zsh already installed at $HOME/.oh-my-zsh"
    return
  fi

  if ! have curl && ! have wget; then
    log "Neither curl nor wget is available to install Oh My Zsh. Please install one of them and re-run."
    return
  fi

  log "Installing Oh My Zsh (non-interactive, KEEP_ZSHRC=yes)..."
  export RUNZSH=no
  export KEEP_ZSHRC=yes
  if have curl; then
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended || log "Warning: Oh My Zsh install script failed."
  else
    sh -c "$(wget -qO- https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended || log "Warning: Oh My Zsh install script failed."
  fi
}

install_antidote() {
  # Prefer a local clone under ~/.antidote for portability.
  if [ -d "$HOME/.antidote" ]; then
    log "Antidote already present at $HOME/.antidote"
    return
  fi
  if ! have git; then
    log "git is required to clone Antidote. Please install git and re-run."
    return
  fi
  log "Cloning Antidote into $HOME/.antidote..."
  git clone https://github.com/mattmc3/antidote.git "$HOME/.antidote" || log "Warning: failed to clone Antidote; plugin management may be unavailable."
}

main() {
  log "Starting portable Zsh setup..."

  ensure_core_tools
  install_oh_my_zsh
  install_antidote

  # Symlink Zsh configuration files from this repo into $HOME.
  link_file "$REPO_DIR/config/zsh/.zshrc" "$HOME/.zshrc"
  link_file "$REPO_DIR/config/zsh/.zshenv" "$HOME/.zshenv"
  link_file "$REPO_DIR/config/zsh/.zsh_plugins.txt" "$HOME/.zsh_plugins.txt"
  link_file "$REPO_DIR/config/zsh/.zsh_plugins.zsh" "$HOME/.zsh_plugins.zsh"

  log "Portable installation complete. Restart your shell or run: exec zsh"
}

main "$@"

