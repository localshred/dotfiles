#!/usr/bin/env zsh

export ERL_AFLAGS="-kernel shell_history enabled"

function elixir_prompt() {
  if [[ -s mix.exs ]]; then
    version=$(asdf current elixir | awk '{print $2}')
    echo "ex:$version"
  fi
}
