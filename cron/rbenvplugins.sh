#!/usr/bin/env bash

pushd $mydotfiles > /dev/null

rbenv_plugins_file=$mydotfiles/data/rbenv-plugins.txt
mkdir -p $mydotfiles/data

# Get a fresh file
rm -f $rbenv_plugins_file
touch $rbenv_plugins_file

pushd $RBENV_ROOT/plugins > /dev/null
  plugins=$(ls -d */ | cut -f1 -d'/' | sort -f)
  for plugin_dir in $plugins; do
    pushd $plugin_dir > /dev/null
      origin=$(git remote -v | grep origin | head -1 | awk '{print $2}')
      sha=$(git rev-parse HEAD)
      echo "${plugin_dir} ${origin} ${sha}" >> $rbenv_plugins_file
    popd > /dev/null
  done
popd > /dev/null

git diff-index --quiet HEAD --
[ $? -eq 0 ] && echo "No changes to rbenv plugins" && exit

count=$(cat ${rbenv_plugins_file} | wc -l)
git add $rbenv_plugins_file
git commit -m "Snapshot ${count} rbenv plugins in ${RBENV_ROOT}/plugins (cron ${0})"
git push origin master
