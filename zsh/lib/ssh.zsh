#!/usr/bin/env zsh

function newkey() {
  local postfix=$1
  local user_comment=${2:-bj.neilsen@gmail.com}
  [[ $postfix == "" ]] && echo "You need to provide a postfix name for the keyfile (e.g. github+localshred)" && return 1

  keyfile=~/.ssh/id_ed25519.$postfix
  echo "Generating your key $keyfile..."
  ssh-keygen -o -a 100 -t ed25519 -f $keyfile -C $user_comment

  echo "Adding to your keychain..."
  ssh-add $keyfile

  chmod 600 $keyfile.pub

  echo "Added your public key to your pasteboard"
  cat $keyfile.pub | pbcopy
}
