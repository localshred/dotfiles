function load_kiex() {
  [[ ! -s mix.exs ]] && return 0
  if ! command -v kiex > /dev/null; then
    test -s "$HOME/.kiex/scripts/kiex" && source "$HOME/.kiex/scripts/kiex"
  fi
}
add-zsh-hook precmd load_kiex

function elixir_prompt() {
  if [[ -s mix.exs ]]; then
    version=""
    if [[ -f .kiexrc ]]; then
      version=$(cat .kiexrc)
      kiex use $version > /dev/null
    fi
    if [[ -z "$version" ]]; then
      version=$(kiex list | egrep "=[\*>] elixir" | awk -F- '{print $2}')
    fi
    echo "elixir:$version"
  fi
}
