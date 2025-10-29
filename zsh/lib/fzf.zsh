#!/usr/bin/env zsh

source <(fzf --zsh)

alias edit="fzf --bind 'enter:become(emacsclient -nw -r -a /opt/homebrew/bin/emacs {}),ctrl-v:become(nvim {})'"
