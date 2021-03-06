#!/usr/bin/env bash

pushd $DOTFILES > /dev/null

vim_plugins_file=$DOTFILES/data/vim-plugins.txt
mkdir -p $DOTFILES/data

# Get a fresh file
rm -f $vim_plugins_file
touch $vim_plugins_file

pushd ~/.vim/bundle > /dev/null
  plugins=$(ls -d */ | cut -f1 -d'/' | sort -f)
  for plugin_dir in $plugins; do
    pushd $plugin_dir > /dev/null
      origin=$(git remote get-url origin)
      if [ "$origin" != "" ]; then
        sha=$(git rev-parse HEAD)
        echo "${plugin_dir} ${origin} ${sha}" >> $vim_plugins_file
      else
        echo "${plugin_dir} is not a git repo, skipping"
      fi
    popd > /dev/null
  done
popd > /dev/null

git diff-index --quiet HEAD --
[ $? -eq 0 ] && echo "No changes to vim plugins" && exit

count=$(cat ${vim_plugins_file} | wc -l)
git add $vim_plugins_file
git commit -m "Snapshot ${count} vim plugins in ~/.vim/bundle (cron ${0})"
git push origin master
