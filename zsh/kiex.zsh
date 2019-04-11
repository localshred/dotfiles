function load_kiex() {
  [[ ! -s mix.exs ]] && return 0
  if ! command -v kiex > /dev/null; then
    test -s "$HOME/.kiex/scripts/kiex" && source "$HOME/.kiex/scripts/kiex"
  fi
}
add-zsh-hook precmd load_kiex
