#!/usr/bin/env zsh

# Combine personal and work CLAUDE.md files into ~/.claude/CLAUDE.md
claudesync() {
  local target="$HOME/.claude/CLAUDE.md"
  local personal="$dotfiles/claude/.claude/CLAUDE.personal.md"
  local work="$dotfiles_work/claude/.claude/CLAUDE.work.md"
  local tmp="$(mktemp)"

  if [[ ! -f "$personal" ]]; then
    echo "CLAUDE.personal.md not found at $personal"
    rm -f "$tmp"
    return 1
  fi

  cat "$personal" >"$tmp"

  if [[ -f "$work" ]]; then
    echo "\n\n# Work\n" >>"$tmp"
    cat "$work" >>"$tmp"
  fi

  if [[ -f "$target" ]] && command diff -q "$tmp" "$target" >/dev/null 2>&1; then
    echo "No changes — $target is already up to date."
    rm -f "$tmp"
    return 0
  else
    echo "got changes"
  fi

  echo ""
  if [[ -f "$target" ]]; then
    colordiff -u "$target" "$tmp"
  else
    echo "New file (no existing $target):"
    cat "$tmp"
  fi

  echo ""
  echo -n "Apply these changes to $target? [y/N] "
  read -r reply
  if [[ "$reply" =~ ^[Yy]$ ]]; then
    cp "$tmp" "$target"
    echo "Updated $target"
  else
    echo "Aborted."
  fi

  rm -f "$tmp"
}
