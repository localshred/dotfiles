#!/usr/bin/env zsh

source $(brew --prefix asdf)/libexec/asdf.sh
export PATH="$PATH:$(asdf where rust)/bin"
