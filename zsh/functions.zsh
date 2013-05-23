function zsh_stats() {
  history | awk '{CMD[$2]++;count++;}END { for (a in CMD)print CMD[a] " " CMD[a]/count*100 "% " a;}' | grep -v "./" | column -c3 -s " " -t | sort -nr | nl |  head -n20
}

function uninstall_oh_my_zsh() {
  /usr/bin/env ZSH=$ZSH /bin/sh $ZSH/tools/uninstall.sh
}

function upgrade_oh_my_zsh() {
  /usr/bin/env ZSH=$ZSH /bin/sh $ZSH/tools/upgrade.sh
}

function take() {
  mkdir -p $1
  cd $1
}

function pbc() {
  cat $@ | pbcopy
}

function hgrep() {
  history | grep $@
}

# Synchronize all local branches, reporting if any failed
function reposync() {
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
        currev=$(git rev-parse $branch)
        syncrev=$(git rev-parse origin/$branch)
        if [[ $currev != $syncrev ]]
        then
          echo " > Synchronizing branch $branch"
          git checkout $branch
          git rebase origin/$branch
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

# Upstream out-of-date branch check (e.g. what does master have that qa doesn't)
function upcherry() {
  echo 'Upstream out-of-date branch check'

  echo '[master > qa]'
  git ch -v qa master

  echo '[qa > stage]'
  git ch -v stage qa

  echo '[stage > stable]'
  git ch -v stable stage

  echo '[stable = int]'
  git ch -v int stable
  git ch -v stable int
}

# Downstream out-of-date branch check (e.g. what does stable have that master doesn't)
function dncherry() {
  echo 'Downstream out-of-date branch check'

  echo '[qa > master]'
  git ch -v master qa

  echo '[stage > qa]'
  git ch -v qa stage

  echo '[stable > stage]'
  git ch -v stage stable

  echo '[stable > master]'
  git ch -v master stable

  echo '[stable = int]'
  git ch -v int stable
  git ch -v stable int
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

function sand() {
  1=${1:=`basename $(pwd)`}
  2=${2:="1"}
  echo "ssh deployer@po-sand-$1$2"
  ssh deployer@po-sand-$1$2
}

function qa() {
  1=${1:=`basename $(pwd)`}
  2=${2:="1"}
  echo "ssh deployer@po-qa-$1$2"
  ssh deployer@po-qa-$1$2
}

function int() {
  1=${1:=`basename $(pwd)`}
  2=${2:="sa"}
  3=${3:="1"}
  echo "ssh bj@${2}-int-$1$3"
  ssh bj@${2}-int-$1$3
}

function stage() {
  1=${1:=`basename $(pwd)`}
  3=${2:="1"}
  echo "ssh bj@sa-stage-$1$2"
  ssh bj@sa-stage-$1$2
}

function prod() {
  1=${1:=`basename $(pwd)`}
  2=${2:="sa"}
  3=${3:="1"}
  echo "ssh bj@${2}-prod-$1$3"
  ssh bj@${2}-prod-$1$3
}