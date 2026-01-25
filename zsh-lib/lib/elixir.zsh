#!/usr/bin/env zsh

export ERL_AFLAGS="-kernel shell_history enabled"

if [[ is_m1_arch ]]; then
  export KERL_CONFIGURE_OPTIONS="--disable-jit"
fi

function elixir_prompt() {
  if [[ -s mix.exs ]]; then
    version=$(asdf current elixir | grep elixir | awk '{print $2}')
    erl_version=$(asdf current erlang | grep erlang | awk '{print $2}')
    echo "ex:$version erl:$erl_version"
  fi
}
