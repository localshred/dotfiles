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

function js_prompt() {
  if [[ -s package.json ]]; then
    version=$(asdf current nodejs | awk '{print $2}')
    echo "js:${version}"
  fi
}
