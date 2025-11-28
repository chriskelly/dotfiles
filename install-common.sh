#!/usr/bin/env bash
# Common functions shared by install scripts

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

