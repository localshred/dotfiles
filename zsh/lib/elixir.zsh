#!/usr/bin/env zsh

function load_kiex() {
  if ! command -v kiex > /dev/null; then
    test -s "$HOME/.kiex/scripts/kiex" && source "$HOME/.kiex/scripts/kiex"
    use_kiex_version
    add-zsh-hook chpwd use_kiex_version
  fi
}

function use_kiex_version() {
  if [[ -s .kiexrc ]]; then
    version=$(cat .kiexrc)
    kiex use $version > /dev/null
    if [[ $? -ne 0 ]]; then
      echo "You haven't installed elixir v$version. Do you want to?"
      read response
      if [[ 'y' == "${response}" ]]; then
        kiex install $version
        kiex use $version
      else
        echo "Skipping elixir v${expected_version} install"
      fi
    fi
  fi
}

function elixir_prompt() {
  if [[ -s mix.exs ]]; then
    version=$(kiex list | egrep "=[\*>] elixir" | awk -F- '{print $2}')
    echo "elixir:$version"
  fi
}

function __autoload_kiex() {
  [[ ! -s mix.exs ]] && return 0
  load_kiex
  add-zsh-hook -d precmd __autoload_kiex
}
add-zsh-hook precmd __autoload_kiex
