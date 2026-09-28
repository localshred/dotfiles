#!/usr/bin/env zsh

alias g='git'
alias gti='git'

ssh-agent-add() {
  em ~/.config/1Password/ssh/agent.toml
}

# gbm: git (checkout) branch main/master
# Checkout the trunk branch on a git repo, prioritizing moratorium, then main,
# and falling back to master.
gbm() {
  if [[ ! -d .git ]]; then
    echo "Not in a git repo"
    return
  fi

  git branch | grep -E "\* (main|master|moratorium|falcon-dev)" >/dev/null
  on_trunk_exit=$?
  if [[ $on_trunk_exit -eq 0 ]]; then
    return
  fi

  for br in falcon-dev moratorium main master; do
    git branch -r | grep "origin/$br"
    repo_uses_branch=$?
    if [[ $repo_uses_branch -eq 0 ]]; then
      git checkout "$br"
      return
    fi
  done

  echo "Didn't find a main branch to checkout"
  return 1
}

# co: git checkout alias
co() {
  branch="$1"

  # If the given branch is fully formed, switch to it
  git rev-parse "origin/$branch" &>/dev/null
  if [[ $? -eq 0 ]]; then
    git checkout "$branch"
    return
  fi

  case "$branch" in
  fm | prod)
    git checkout falcon-main
    ;;

  fs | st | stage | staging | perf | rel | release)
    git checkout falcon-release
    ;;

  fd | dev)
    git checkout falcon-dev
    ;;

  mor | org62)
    git checkout moratorium
    ;;

  m | ma | mo | t | tr | trunk)
    gbm
    ;;

  -)
    git checkout -
    ;;

  *)
    git checkout "$branch"
    ;;
  esac
}

# reposync: rebase every local branch onto its origin counterpart,
# auto-stashing/popping local changes around the sync
reposync() {
  color_red="\e[31m"
  color_green="\e[32m"
  color_yellow="\e[33m"
  color_reset="\e[39m"
  rc=0

  git status &>/dev/null
  [ $? -ne 0 ] && echo "${color_red}Not a git repository${color_reset}" && return 1

  git remote update origin --prune >/dev/null
  [ $? -ne 0 ] && echo "${color_red}Could not fetch origin${color_reset}" && return 2

  stashed=0
  if [ -n "$(git status --porcelain)" ]; then
    print_info "Stashing local changes"
    git stash push --include-untracked --quiet -m "reposync autostash"
    [ $? -ne 0 ] && echo "${color_red}Could not stash local changes, aborting${color_reset}" && return 3
    stashed=1
  fi

  missing=()
  up_to_date=()
  updated=()
  start_branch=$(git rev-parse --abbrev-ref HEAD)

  for branch in $(git for-each-ref --format='%(refname:short)' refs/heads/); do
    print_info "Syncing ${branch}"
    git rev-parse origin/$branch &>/dev/null
    if [[ $? -eq 0 ]]; then
      local_head=$(git rev-parse --short $branch)
      remote_head=$(git rev-parse --short origin/$branch)
      if [[ $local_head != $remote_head ]]; then
        git checkout $branch --quiet
        commits_behind=$(git rev-list $remote_head "^$local_head" --count)
        updated+="[${branch}] rebase from ${local_head} to ${remote_head} ($commits_behind commits behind)"
        print_command "git rebase origin/${branch} --quiet"
        git rebase origin/${branch} --quiet
        if [[ $? -ne 0 ]]; then
          print_error "Failed to rebase branch ${branch}, skipping for now"
          run_command "git rebase --abort"
          rc=4
        fi
      else
        up_to_date+=$branch
      fi
    else
      missing+=$branch
    fi
  done

  current_branch=$(git rev-parse --abbrev-ref HEAD)
  [ $start_branch != $current_branch ] && git checkout $start_branch --quiet

  if [[ $stashed -eq 1 ]]; then
    print_info "Restoring stashed changes"
    git stash pop --quiet
    [ $? -ne 0 ] && echo "${color_yellow}Stash pop conflicted; resolve manually (git stash list)${color_reset}" && rc=5
  fi

  [[ -n "${up_to_date}" ]] && for branch in $up_to_date; do echo "${color_green}[${branch}] up to date${color_reset}"; done
  [[ -n "${updated}" ]] && for updated_description in $updated; do echo "${color_green}${updated_description}${color_reset}"; done
  [[ -n "${missing}" ]] && for branch in $missing; do echo "${color_yellow}[${branch}] missing on origin${color_reset}"; done

  return $rc
}

# reposyncdirs: run reposync in every immediate subdirectory
reposyncdirs() {
  rc=0
  for dir in $(ls -d */); do
    print_warn ">>> Dir: ${dir}"
    pushd $dir >/dev/null
    gbm
    reposync || rc=1
    popd >/dev/null
    print_success ">>> Done"
  done

  return $rc
}
