#!/usr/bin/env zsh

# Combine personal and work CLAUDE.md files into ~/.claude/CLAUDE.md
claudesync() {
  local target="$HOME/.claude/CLAUDE.md"
  local personal="$dotfiles/claude/.claude/CLAUDE.md"
  local work="$dotfiles_work/claude/CLAUDE.md"

  if [[ ! -f "$personal" ]]; then
    echo "Personal CLAUDE.md not found at $personal"
    return 1
  fi

  cat "$personal" > "$target"

  if [[ -n "$dotfiles_work" && -f "$work" ]]; then
    echo "" >> "$target"
    cat "$work" >> "$target"
    echo "Combined personal + work CLAUDE.md -> $target"
  else
    echo "Copied personal CLAUDE.md -> $target"
  fi
}
