#!/usr/bin/env zsh

function zshpath() { nvim $DOTFILES/zsh/load/path.zsh }
function rebuildpath() { source $DOTFILES/zsh/load/path.zsh }

PATH=/usr/local/bin
PATH=$PATH:$DOTFILES/bin
PATH=$PATH:/usr/local/sbin
PATH=$PATH:/usr/bin
PATH=$PATH:/bin
PATH=$PATH:$HOME/bin
PATH=$PATH:$HOME/.config/emacs/bin
PATH=$PATH:/usr/sbin
PATH=$PATH:/sbin
PATH=$PATH:/usr/X11/bin
PATH=$PATH:$CODE/src/utilities/ephemer/bin
PATH=$PATH:$HOME/node_modules/.bin
PATH=$PATH:$HOME/.yarn/bin
PATH=$PATH:/usr/local/opt/go/libexec/bin
PATH=$PATH:$GOBIN
PATH=$PATH:$HOME/.pyenv/bin
PATH=$PATH:$HOME/Library/Python/3.8/bin
PATH=$PATH:/usr/local/opt/mysql-client/bin
PATH=$PATH:/Applications/Docker.app/Contents/Resources/bin

if [[ -d "$ANDROID_HOME" ]]; then
    PATH=$PATH:$ANDROID_HOME/emulator
    PATH=$PATH:$ANDROID_HOME/platform-tools
fi

export PATH

