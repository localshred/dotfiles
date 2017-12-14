function agvim() {
  args=$@
  files=$(ag -l "${args}")
  echo $files
  echo "Do you want to edit the preceding files? (y/n)"
  read response
  if [[ 'y' == "${response}" ]]; then
    vim $(echo $files)
  fi
}

function vimupdateplugins() {
  for plugin_dir in $(find ~/.vim/bundle -type d -maxdepth 1 -mindepth 1); do
    pushd $plugin_dir > /dev/null
    git fetch origin master --quiet
    local_head=$(git rev-parse --short HEAD)
    remote_head=$(git rev-parse --short origin/master)
    plugin_name=$(basename $plugin_dir)
    if [[ $local_head != $remote_head ]]
    then
      commits_behind=$(git rev-list $remote_head "^$local_head" --count)
      echo "Updating ${plugin_name} from ${local_head} to ${remote_head} ($commits_behind commits behind)"
      git rebase origin/master --quiet
    else
      echo "${plugin_name} is already up to date"
    fi
    popd > /dev/null
  done
}

function vimraw() {
  vim -u NONE -U NONE -N $@
}
