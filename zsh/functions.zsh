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

function dash()
{
  open "dash://$@"
}

function git_cur_branch()
{
  ref=$(git symbolic-ref HEAD 2> /dev/null) || return
  "${ref#refs/heads/}"
}

# Grep ps output
function psgrep()
{
  ps aux | grep $@
}

# Grep the history.
function hgrep()
{
  history | grep $@
}

# Cat the contents of the file and put it in
# the pastboard.
#
#   `pbc foo.txt`
function pbc()
{
  cat $@ | pbcopy
}

# Synchronize all local branches, reporting if any failed
function reposync()
{
  git status &> /dev/null
  if [ $? -eq 0 ]; then
    git diff-index --quiet HEAD --
    [ $? -ne 0 ] && echo "You have local changes that haven't been commited" && return
    git remote update origin --prune

    failedbranches=()
    startbranch=$(git branch  | grep '*' | sed -e 's/* //')
    for branch in $(git branch | sed -e 's|* ||g' -e 's|^[ ]*||')
    do
      git rev-parse origin/$branch &> /dev/null
      if [[ $? -eq 0 ]]
      then
        local_head=$(git rev-parse --short $branch)
        remote_head=$(git rev-parse --short origin/$branch)
        if [[ $local_head != $remote_head ]]
        then
          echo " > Synchronizing branch $branch"
          git checkout $branch --quiet
          commits_behind=$(git log $local_head..$remote_head --pretty=oneline | wc -l | awk '{print $1 " commits behind"}')
          echo "Updating ${branch} from ${local_head} to ${remote_head} ($commits_behind)"
          git rebase origin/$branch --quiet
        fi
      else
        echo " ! Branch $branch doesn't have an origin"
        failedbranches+=$branch
      fi
    done
    [ "${#failedbranches}" -gt 0 ] && echo " ! Failed syncing branches" && echo " ! Delete: git branch -d $failedbranches"

    curbranch=$(git branch | grep '*' | sed -e 's/* //')
    [ $startbranch != $curbranch ] && git checkout $startbranch
    echo "Local branches are up-to-date"
  else
    echo "Not a git repository"
  fi
}

function take() {
  mkdir -p $1
  cd $1
}

# Upstream out-of-date branch check (e.g. what does master have that qa doesn't)
function upcherry() {
  echo 'Upstream out-of-date branch check'

  echo '[master > stage]'
  git ch -v stage master

  echo '[stage > prod]'
  git ch -v prod stage
}

# Downstream out-of-date branch check (e.g. what does stable have that master doesn't)
function dncherry() {
  echo 'Downstream out-of-date branch check'

  echo '[master < stage]'
  git ch -v master stage

  echo '[stage < prod]'
  git ch -v stage prod
}

# Run the upcherry command against all repos (does not assume up-to-date)
function srvupcherry()
{
  for repo in $(ls /code/src/services);
  do
    echo $(basename $repo)
    cd $repo
    upcherry
    echo '----'
    echo
  done
}

# Run the dncherry command against all repos (does not assume up-to-date)
function srvdncherry()
{
  for repo in $(ls /code/src/services);
  do
    echo $(basename $repo)
    cd $repo
    dncherry
    echo '----'
    echo
  done
}

function srvreposync()
{
  for repo in $(ls /code/src/services);
  do
    echo $(basename $repo)
    cd $repo
    reposync
    echo '----'
  done
}

function sand()
{
  1=${1:=`basename $(pwd)`}
  2=${2:="1"}
  echo "ssh deployer@po-sand-$1$2"
  ssh deployer@po-sand-$1$2
}

function qa()
{
  1=${1:=`basename $(pwd)`}
  2=${2:="1"}
  echo "ssh deployer@po-qa-$1$2"
  ssh deployer@po-qa-$1$2
}

function int()
{
  1=${1:=`basename $(pwd)`}
  2=${2:="sa"}
  3=${3:="1"}
  echo "ssh bj@${2}-int-$1$3"
  ssh bj@${2}-int-$1$3
}

function stage()
{
  1=${1:=`basename $(pwd)`}
  3=${2:="1"}
  echo "ssh bj@sc-stage-$1$2"
  ssh bj@sc-stage-$1$2
}

function prod()
{
  1=${1:=`basename $(pwd)`}
  2=${2:="sb"}
  3=${3:="1"}
  echo "ssh bj@${2}-prod-$1$3"
  ssh bj@${2}-prod-$1$3
}

function zsh_stats()
{
  history | awk '{CMD[$2]++;count++;}END { for (a in CMD)print CMD[a] " " CMD[a]/count*100 "% " a;}' | grep -v "./" | column -c3 -s " " -t | sort -nr | nl |  head -n20
}

function ptreb() {
  bin/treb "$@" > log/deploy.log | egrep '(=+\[\w+\]===|(Currently|^\s+\*) executing|^Group \d+|^cap |^ \*\* )'
}

function lintchanged() {
  git diff --name-only | xargs ./node_modules/.bin/eslint --quiet
}

function recent() {
  period=${1:-15m}
  find . -type f -mtime -$period | grep -v '\.git'
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
      commits_behind=$(git log $local_head..$remote_head --pretty=oneline | wc -l | awk '{print $1 " commits behind"}')
      echo "Updating ${plugin_name} from ${local_head} to ${remote_head} ($commits_behind)"
      git rebase origin/master --quiet
    else
      echo "${plugin_name} is already up to date"
    fi
    popd > /dev/null
  done
}
