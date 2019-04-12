#!/usr/bin/env zsh

function zshpath() { vim $DOTFILES/zsh/load/path.zsh }

PATH=/usr/local/bin
PATH=$PATH:/usr/local/sbin
PATH=$PATH:/usr/bin
PATH=$PATH:/bin
PATH=$PATH:/usr/sbin
PATH=$PATH:/sbin
PATH=$PATH:/usr/X11/bin
PATH=$PATH:/code/src/utilities/ephemer/bin
PATH=$PATH:/Users/bj/Library/Python/3.7/bin
PATH=$PATH:/Users/bj/node_modules/.bin
PATH=$PATH:$HOME/.yarn/bin
PATH=$PATH:/usr/local/opt/go/libexec/bin
PATH=$PATH:$GOBIN
PATH=$PATH:/Users/bj/.pyenv/bin
export PATH

