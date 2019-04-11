#!/usr/bin/env zsh

function zshenv() { vim $DOTFILES/zsh/load/env.zsh }

export ECTO_EDITOR=nvim
export EDITOR=nvim
export GOBIN=/code/src/go/bin
export GOPATH=/code/src/go
export GOVERSION=$(go version | awk -Fgo '{print $3}' | awk '{print $1}')
export JAVA_HOME=$(/usr/libexec/java_home)
export REACT_EDITOR=nvim
export VISIONBOARD=~/Dropbox/BJ/vision/vision.md
