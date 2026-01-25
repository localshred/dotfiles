#!/usr/bin/env zsh

alias brewsync='brew bundle check --file="$dotfiles/Brewfile" && brew bundle cleanup --file="$dotfiles/Brewfile"'
