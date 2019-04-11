function load_rbenv() {
  [[ ! -s Gemfile ]] && return 0
  if ! command -v rbenv > /dev/null; then
    eval "$(rbenv init -)"
  fi
}
