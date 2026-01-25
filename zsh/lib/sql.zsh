#!/usr/bin/env zsh

pgf() {
  printf "Paste SQL, then \\\n+^D:"
  v=$(pg_format -)
  printf "\n\nFormatted:\n%s" "$v"
  echo "$v" | pbcopy
}
