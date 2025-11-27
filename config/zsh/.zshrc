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
    if [ ! -f "$HOME/.zsh_plugins.zsh" ] || [ "$HOME/.zsh_plugins.txt" -nt "$HOME/.zsh_plugins.zsh" ]; then
      antidote bundle < "$HOME/.zsh_plugins.txt" > "$HOME/.zsh_plugins.zsh"
    fi
  fi
fi

if [ -f "$HOME/.zsh_plugins.zsh" ]; then
  source "$HOME/.zsh_plugins.zsh"
fi

##### Prompt tweaks ###########################################################

# Hide the username in the prompt when it matches the current user.
DEFAULT_USER="$USER"

##### Host-specific configuration #############################################

# macOS-specific additions live in ~/.zshrc.mac, sourced only on Darwin.
if [[ "$OSTYPE" == darwin* ]] && [ -f "$HOME/.zshrc.mac" ]; then
  source "$HOME/.zshrc.mac"
fi


