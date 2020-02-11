#!/usr/bin/env zsh

function zshenv() { vim $DOTFILES/zsh/load/env.zsh }

export DEFAULT_JABBA_VERSION="adopt@1.8.0-232"
export ECTO_EDITOR=nvim
export EDITOR=nvim
export GPG_TTY=$(tty)
export GOPATH=$CODE/src/go
export GOBIN=$GOPATH/bin
export GOVERSION=$(go version | awk -Fgo '{print $3}' | awk '{print $1}')
export JAVA_HOME=$(/usr/libexec/java_home)
export REACT_EDITOR=nvim
export VISIONBOARD=~/Dropbox/BJ/vision/vision.md

export BITT_SOURCE_BASEDIR=$CODE/src/bitt/neo
export BITT_CHAINCODE_SOURCE_BASEDIR=$CODE/src/bitt/neo/chaincode
export BITT_GIT_HOST=bitbucket.org
export BITT_GIT_HOST_BASE_PATH=mediciventures
