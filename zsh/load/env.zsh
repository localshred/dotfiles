#!/usr/bin/env zsh

function zshenv() { vim $DOTFILES/zsh/load/env.zsh }

## export CODE, DOTFILES from .zshrc

export ECTO_EDITOR=emacs
export EDITOR=emacs
export ERL_AFLAGS="-kernel shell_history enabled"
export GOBIN=$GOPATH/bin
export GOPATH=$CODE/src/go
if hash go 2> /dev/null; then
  export GOVERSION=$(go version | awk -Fgo '{print $3}' | awk '{print $1}')
fi
export GPG_TTY=$(tty)
export JAVA_HOME=$(/usr/libexec/java_home)
export LANG=en_US.UTF-8
export LANGUAGE=en_US.UTF-8
export LC_ALL=en_US.UTF-8
export REACT_EDITOR=emacs
export TERM=xterm-24bit
export VISIONBOARD=~/Dropbox/BJ/vision/vision.md

cdpath=(~ ~/Documents ~/Desktop
  $CODE $CODE/src $CODE/src/localshred $CODE/src/crx $CODE/src/utilities
  $CODE/src/spiff $CODE/src/nuid $GOPATH/src/github.com $GOPATH/src/gitlab.com)
