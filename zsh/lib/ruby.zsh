#!/usr/bin/env zsh

function load_rbenv() {
  [[ ! -s Gemfile ]] && return 0
  if [[ -z $RBENV_LOADED ]]; then
    eval "$(rbenv init -)"
    export RBENV_LOADED=1
    add-zsh-hook -d precmd load_rbenv
  fi
}
add-zsh-hook precmd load_rbenv

function ruby_prompt() {
  if [[ -s Gemfile ]]; then
    version=$(rbenv version | awk '{print $1}')
    echo "ruby:$version"
  fi
}
