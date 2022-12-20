#!/usr/bin/env zsh

function zshenv() { vim $DOTFILES/zsh/load/env.zsh }

## export CODE, DOTFILES from .zshrc

export DEFAULT_JABBA_VERSION="adopt@1.8.0-232"
export DEFAULT_NVM_VERSION="12.15.0"
export ECTO_EDITOR=nvim
export EDITOR=nvim
export GPG_TTY=$(tty)
export GOPATH=$CODE/src/go
export GOBIN=$GOPATH/bin
export GOVERSION=$(go version | awk -Fgo '{print $3}' | awk '{print $1}')
export JAVA_HOME=$(/usr/libexec/java_home)
export LC_ALL=en_US.UTF-8
export LANG=en_US.UTF-8
export LANGUAGE=en_US.UTF-8
export REACT_EDITOR=nvim
export TERM=xterm-24bit
export VISIONBOARD=~/Dropbox/BJ/vision/vision.md

cdpath=(~ ~/Documents ~/Desktop
  $CODE $CODE/src $CODE/src/localshred $CODE/src/crx $CODE/src/utilities
  $CODE/src/commsor $CODE/src/nuid $GOPATH/src/github.com $GOPATH/src/gitlab.com)
