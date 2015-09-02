#!/usr/bin/env bash

pushd $mydotfiles > /dev/null

vim_plugins_file=$mydotfiles/data/vim-plugins.txt
mkdir -p $mydotfiles/data

# Get a fresh file
rm -f $vim_plugins_file
touch $vim_plugins_file

pushd ~/.vim/bundle > /dev/null
  plugins=$(ls -d */ | cut -f1 -d'/' | sort -f)
  for plugin_dir in $plugins; do
    pushd $plugin_dir > /dev/null
      origin=$(git remote -v | grep origin | head -1 | awk '{print $2}')
      sha=$(git rev-parse HEAD)
      echo "${plugin_dir} ${origin} ${sha}" >> $vim_plugins_file
    popd > /dev/null
  done
popd > /dev/null

git diff-index --quiet HEAD --
[ $? -eq 0 ] && echo "No changes to vim plugins" && exit

count=$(cat ${vim_plugins_file} | wc -l)
git add $vim_plugins_file
git commit -m "Snapshot ${count} vim plugins in ~/.vim/bundle (cron ${0})"
git push origin master
