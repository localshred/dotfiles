#!/usr/bin/env zsh

function ruby_prompt() {
  if [[ -s Gemfile || -s .ruby-version ]]; then
    version=$(ruby --version | awk '{print $2}' | awk -Fp '{print $1}')
    echo "ruby:$version"
  fi
}
