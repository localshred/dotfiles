#!/usr/bin/env zsh

# Combine personal and work CLAUDE.md files into ~/.claude/CLAUDE.md
# Also syncs commands from work dotfiles into ~/.claude/commands/
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
  else
    echo "got changes"
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
  fi

  _claudesync_commands
}

_claudesync_commands() {
  local target_dir="$HOME/.claude/commands"
  local work_commands="$dotfiles_work/claude/.claude/commands"

  if [[ ! -d "$work_commands" ]]; then
    return 0
  fi

  mkdir -p "$target_dir"

  local changed=0
  for src in "$work_commands"/*.md; do
    [[ -f "$src" ]] || continue
    local name="$(basename "$src")"
    local dest="$target_dir/$name"
    if [[ ! -f "$dest" ]] || ! command diff -q "$src" "$dest" >/dev/null 2>&1; then
      changed=1
      break
    fi
  done

  if (( changed == 0 )); then
    echo "Commands: no changes."
    return 0
  fi

  echo ""
  echo "Command files to sync:"
  for src in "$work_commands"/*.md; do
    [[ -f "$src" ]] || continue
    local name="$(basename "$src")"
    local dest="$target_dir/$name"
    if [[ ! -f "$dest" ]]; then
      echo "  + $name (new)"
    elif ! command diff -q "$src" "$dest" >/dev/null 2>&1; then
      echo "  ~ $name (changed)"
    fi
  done

  echo ""
  echo -n "Sync commands to $target_dir? [y/N] "
  read -r reply
  if [[ "$reply" =~ ^[Yy]$ ]]; then
    cp "$work_commands"/*.md "$target_dir/"
    echo "Commands synced."
  else
    echo "Commands sync aborted."
  fi
}
