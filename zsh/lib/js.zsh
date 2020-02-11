#!/usr/bin/env zsh

function lintchanged() {
  git diff --name-only | xargs ./node_modules/.bin/eslint --quiet
}

function npmedit() {
  package=$1
  vim node_modules/$package/package.json -c "NERDTree node_modules/$package"
}

function npmver() {
  package=$1
  jq '.version' node_modules/$package/package.json | awk -F\" '{print $2}'
}

function nb() {
  program=$1
  shift
  ./node_modules/.bin/$program $@
}

function nr() {
  script=$1
  shift
  npm run $script -- $@
}

function use_nvm_version() {
  [[ ! -s package.json && ! -s .nvmrc ]] && return 0

  local node_version="$(nvm version)"
  local nvmrc_path="$(nvm_find_nvmrc)"

  if [ -n "$nvmrc_path" ]; then
    local expected_version=$(cat "${nvmrc_path}")
    local nvmrc_node_version=$(nvm version "${expected_version}")

    if [ "$nvmrc_node_version" = "N/A" ]; then
      echo "You haven't installed node ${expected_version}. Do you want to?"
      read response
      if [[ 'y' == "${response}" ]]; then
        nvm install
      else
        echo "Skipping node ${expected_version} install"
      fi
    elif [ "$nvmrc_node_version" != "$node_version" ]; then
      nvm use --silent
    fi
  elif [ "$node_version" != "$(nvm version default)" ]; then
    nvm use --silent default
  fi
}

function load_nvm() {
  if ! command -v nvm > /dev/null; then
    export NVM_DIR="/Users/bj/.nvm"
    [ -s "/usr/local/opt/nvm/nvm.sh" ] && source "/usr/local/opt/nvm/nvm.sh"  # This loads nvm
    [ -s "/usr/local/opt/nvm/etc/bash_completion.d/nvm" ] && source "/usr/local/opt/nvm/etc/bash_completion.d/nvm"  # This loads nvm bash_completion

    nvm alias default $DEFAULT_NVM_VERSION
    use_nvm_version
    add-zsh-hook chpwd use_nvm_version
  fi
}

function js_prompt() {
  if [[ -s package.json || -s .nvmrc ]]; then
    version=$(nvm current)
    echo "js:${version/v/}"
  fi
}

function __autoload_nvm() {
  [[ ! -s package.json && ! -s .nvmrc ]] && return 0
  load_nvm
  add-zsh-hook -d precmd __autoload_nvm
}
add-zsh-hook precmd __autoload_nvm
