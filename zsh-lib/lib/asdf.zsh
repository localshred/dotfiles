#!/usr/bin/env zsh

source "$HOMEBREW_PREFIX/opt/asdf/libexec/asdf.sh"

# Lazy-load rust path only when needed
rust_path() {
  local rust_bin="$(asdf where rust 2>/dev/null)/bin"
  [[ -d "$rust_bin" ]] && export PATH="$PATH:$rust_bin"
}
