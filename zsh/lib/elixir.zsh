#!/usr/bin/env zsh

function elixir_prompt() {
  if [[ -s mix.exs ]]; then
    version=$(asdf current elixir | awk '{print $2}')
    echo "ex:$version"
  fi
}
