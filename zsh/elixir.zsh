function load_kiex() {
  [[ ! -s mix.exs ]] && return 0
  if ! command -v kiex > /dev/null; then
    test -s "$HOME/.kiex/scripts/kiex" && source "$HOME/.kiex/scripts/kiex"
  fi
}
add-zsh-hook precmd load_kiex

function set_kiex_version() {
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
add-zsh-hook precmd set_kiex_version

function elixir_prompt() {
  if [[ -s mix.exs ]]; then
    version=$(kiex list | egrep "=[\*>] elixir" | awk -F- '{print $2}')
    echo "elixir:$version"
  fi
}
