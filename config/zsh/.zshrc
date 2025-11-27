#!/usr/bin/env zsh

# Portable Zsh configuration
# - Designed to work in devcontainers, SSH sessions, and macOS
# - Keeps machine-specific PATH tweaks in a separate file (see ~/.zshrc.mac)

##### Oh My Zsh ###############################################################

export ZSH="$HOME/.oh-my-zsh"

# Theme + core plugins from Oh My Zsh
ZSH_THEME="agnoster"
plugins=(git)

if [ -f "$ZSH/oh-my-zsh.sh" ]; then
  source "$ZSH/oh-my-zsh.sh"
fi

##### Completion ##############################################################

autoload -U +X bashcompinit && bashcompinit
autoload -Uz compinit
compinit

##### Antidote plugin manager #################################################

# Prefer a local Antidote clone in the home directory.
if [ -f "$HOME/.antidote/antidote.zsh" ]; then
  source "$HOME/.antidote/antidote.zsh"
fi

# If the antidote command is available, (re)build the plugin bundle when needed.
if command -v antidote >/dev/null 2>&1; then
  if [ -f "$HOME/.zsh_plugins.txt" ]; then
    local needs_regen=0
    if [ ! -f "$HOME/.zsh_plugins.zsh" ]; then
      needs_regen=1
    elif [ "$HOME/.zsh_plugins.txt" -nt "$HOME/.zsh_plugins.zsh" ]; then
      needs_regen=1
    else
      # Check if the bundle is just a stub (only comments) or has invalid paths
      # This handles cases where the bundle was generated on macOS but is used in a devcontainer
      if [ -f "$HOME/.zsh_plugins.zsh" ]; then
        # First, check for old macOS-specific paths (quick check)
        if grep -q "/Users/chris/Library/Caches/antidote" "$HOME/.zsh_plugins.zsh" 2>/dev/null; then
          needs_regen=1
        else
          local has_source=0
          local has_invalid=0
          while IFS= read -r line; do
            # Skip empty lines and comments
            [[ -z "$line" || "$line" =~ ^[[:space:]]*# ]] && continue
            # Check for source lines
            if [[ "$line" =~ ^source[[:space:]]+(.+) ]]; then
              has_source=1
              local src_path="$match[1]"
              # Remove any quotes around the path
              src_path="${src_path%\"}"
              src_path="${src_path#\"}"
              if [ ! -f "$src_path" ]; then
                has_invalid=1
                break
              fi
            fi
          done < "$HOME/.zsh_plugins.zsh"
          # Regenerate if no source lines found (stub file) or if any paths are invalid
          if [ "$has_source" -eq 0 ] || [ "$has_invalid" -eq 1 ]; then
            needs_regen=1
          fi
        fi
      fi
    fi
    if [ "$needs_regen" -eq 1 ]; then
      antidote bundle < "$HOME/.zsh_plugins.txt" > "$HOME/.zsh_plugins.zsh"
    fi
  fi
fi

# Only source the bundle if it exists and we're confident it's valid
# (either it was just regenerated, or it passed all validation checks)
if [ -f "$HOME/.zsh_plugins.zsh" ]; then
  # Quick validation: ensure it doesn't contain old macOS paths
  if ! grep -q "/Users/chris/Library/Caches/antidote" "$HOME/.zsh_plugins.zsh" 2>/dev/null; then
    source "$HOME/.zsh_plugins.zsh"
  else
    # If we somehow still have old paths, try to regenerate one more time
    if command -v antidote >/dev/null 2>&1 && [ -f "$HOME/.zsh_plugins.txt" ]; then
      antidote bundle < "$HOME/.zsh_plugins.txt" > "$HOME/.zsh_plugins.zsh"
      source "$HOME/.zsh_plugins.zsh"
    fi
  fi
fi

##### Prompt tweaks ###########################################################

# Hide the username in the prompt when it matches the current user.
DEFAULT_USER="$USER"

##### Host-specific configuration #############################################

# macOS-specific additions live in ~/.zshrc.mac, sourced only on Darwin.
if [[ "$OSTYPE" == darwin* ]] && [ -f "$HOME/.zshrc.mac" ]; then
  source "$HOME/.zshrc.mac"
fi


