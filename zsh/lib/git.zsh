#!/usr/bin/env zsh

alias git='hub'
alias g='git'
alias gti='git'

function pgpkeygen() {
  echo "Generating your pgp key..."
  keybase login
  keybase pgp gen --multi

  echo "Getting key id"
  key_id=$(gpg --list-secret-keys --keyid-format LONG | grep sec | awk -F/ '{print $2}' | awk '{print $1}')

	echo "Setting git signing key"
	git config --global user.signingkey $key_id

  echo "Getting pgp key armor format"
	keybase pgp export -q $key_id | pbcopy
	pbpaste

	echo "Added public key to pasteboard"
	open https://github.com/settings/keys
}

function reposync()
{
  color_red="\e[31m"
  color_green="\e[32m"
  color_yellow="\e[33m"
  color_reset="\e[39m"

  git status &> /dev/null
  [ $? -ne 0 ] && echo "${color_red}Not a git repository${color_reset}" && return

  git diff-index --quiet HEAD --
  [ $? -ne 0 ] && echo "${color_yellow}You have local changes that haven't been commited${color_reset}" && return

  git remote update origin --prune > /dev/null
  [ $? -ne 0 ] && echo "${color_red}Could not fetch origin${color_reset}" && return

  missing=()
  up_to_date=()
  updated=()
  start_branch=$(git rev-parse --abbrev-ref HEAD)
  for branch in $(git for-each-ref --format='%(refname:short)' refs/heads/)
  do
    git rev-parse origin/$branch &> /dev/null
    if [[ $? -eq 0 ]]
    then
      local_head=$(git rev-parse --short $branch)
      remote_head=$(git rev-parse --short origin/$branch)
      if [[ $local_head != $remote_head ]]
      then
        git checkout $branch --quiet
        commits_behind=$(git rev-list $remote_head "^$local_head" --count)
        updated+="[${branch}] rebase from ${local_head} to ${remote_head} ($commits_behind commits behind)"
        git rebase origin/$branch --quiet
      else
        up_to_date+=$branch
      fi
    else
      missing+=$branch
    fi
  done

  current_branch=$(git rev-parse --abbrev-ref HEAD)
  [ $start_branch != $current_branch ] && git checkout $start_branch --quiet

  [[ -n "${up_to_date}" ]] && for branch in $up_to_date; do echo "${color_green}[${branch}] up to date${color_reset}"; done
  [[ -n "${updated}" ]] && for updated_description in $updated; do echo "${color_green}${updated_description}${color_reset}"; done
  [[ -n "${missing}" ]] && for branch in $missing; do echo "${color_yellow}[${branch}] missing on origin${color_reset}"; done
}

function reposyncdirs()
{
  for dir in $(ls)
  do
    echo ">>> [Dir: $dir]"
    pushd $dir > /dev/null
    git checkout master
    reposync
    popd > /dev/null
    echo ">>> Done"
  done
}
