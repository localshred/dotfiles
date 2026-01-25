#!/usr/bin/env zsh

function zshenv() { vim $dotfiles/zsh/load/env.zsh }

## export code, dotfiles from .zshrc

export ANDROID_HOME=$HOME/Library/Android/sdk
export EDITOR="emacsclient -t"
export ECTO_EDITOR=$EDITOR
export ERL_AFLAGS="-kernel shell_history enabled"
export GOPATH=$code/src/go
export GOBIN=$GOPATH/bin
if command -v go &>/dev/null; then
  export GOVERSION=$(go version | awk -Fgo '{print $3}' | awk '{print $1}')
fi
export GPG_TTY=$(tty)
export JAVA_HOME=/Library/Java/JavaVirtualMachines/zulu-11.jdk/Contents/Home
export LANG=en_US.UTF-8
export LANGUAGE=en_US.UTF-8
export LC_ALL=en_US.UTF-8
export MANPAGER='nvim +Man!'
export REACT_EDITOR=$EDITOR
export SSH_AUTH_SOCK="$HOME/Library/Group Containers/2BUA8C4S2C.com.1password/t/agent.sock"
export TERM=xterm-24bit
export VISIONBOARD=~/Dropbox/BJ/vision/vision.md
export VISUAL="emacsclient -c -a /opt/homebrew/bin/emacs"

cdpath=(~ ~/Documents ~/Desktop
  $code $code/src $code/src/localshred $code/src/crx $code/src/utilities
  $GOPATH/src/github.com $GOPATH/src/gitlab.com)
