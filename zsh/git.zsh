alias g='git'
alias git='hub'
alias gti='git'

function reposync()
{
  color_red="\e[31m"
  color_green="\e[32m"
  color_yellow="\e[33m"
  color_reset="\e[39m"

  git status &> /dev/null
  if [ $? -eq 0 ]; then
    git diff-index --quiet HEAD --
    [ $? -ne 0 ] && echo "${color_yellow}You have local changes that haven't been commited${reset_color}" && return
    git remote update origin --prune > /dev/null

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
    [[ -n "${up_to_date}" ]] && for branch in $up_to_date; do echo "${color_green}[${branch}] up to date${reset_color}"; done
    [[ -n "${updated}" ]] && for updated_description in $updated; do echo "${color_green}${updated_description}${reset_color}"; done
    [[ -n "${missing}" ]] && for branch in $missing; do echo "${color_yellow}[${branch}] missing on origin${reset_color}"; done
  else
    echo "${red_color}Not a git repository${reset_color}"
  fi
}

