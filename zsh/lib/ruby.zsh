#!/usr/bin/env zsh

function load_rbenv() {
  if [[ -z $RBENV_LOADED ]]; then
    eval "$(rbenv init -)"
    export RBENV_LOADED=1
  fi
}

function ruby_prompt() {
  if [[ -s Gemfile ]]; then
    version=$(rbenv version | awk '{print $1}')
    echo "ruby:$version"
  fi
}

function __autoload_rbenv() {
  [[ ! -s Gemfile ]] && return 0
  load_rbenv
  add-zsh-hook -d precmd __autoload_rbenv
}
add-zsh-hook precmd __autoload_rbenv
