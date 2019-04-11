#!/usr/bin/env bash

if [[ -z "$DOTFILES" ]]; then
  echo '$DOTFILES is empty'
  exit 1
fi

cd $DOTFILES
brew_formulae_file=$DOTFILES/data/brew-formulae.txt
mkdir -p $DOTFILES/data
touch $brew_formulae_file
brew list --versions | sort > $brew_formulae_file

git diff-index --quiet HEAD --
[ $? -eq 0 ] && echo "No changes to brew formulae" && exit

count=$(cat ${brew_formulae_file} | wc -l)
git add $brew_formulae_file
git commit -m "Snapshot ${count} brew formulae (cron ${0})"
git push origin master
