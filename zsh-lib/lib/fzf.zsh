#!/usr/bin/env zsh

source <(fzf --zsh)

export FZF_DEFAULT_OPTS="--height 40% --layout=reverse --border"

alias edit="fzf --bind 'enter:become(emacsclient -nw -r -a /opt/homebrew/bin/emacs {}),ctrl-v:become(nvim {})'"
