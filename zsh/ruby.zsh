function load_rbenv() {
  [[ ! -s Gemfile ]] && return 0
  if ! command -v rbenv > /dev/null; then
    eval "$(rbenv init -)"
  fi
}

function ruby_prompt() {
  if [[ -s Gemfile ]]; then
    version=$(rbenv version | awk '{print $1}')
    echo "ruby:$version"
  fi
}
