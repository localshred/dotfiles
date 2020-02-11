function use_jabba_version() {
  [[ ! -s .jabbarc ]] && return 0

  local expected_version=$(cat .jabbarc)
  local java_version="$(jabba current)"

  local jabbarc_java_version=$(jabba which $expected_version)

  if [ -z "$jabbarc_java_version" ]; then
    echo "You haven't installed java ${expected_version}. Do you want to? (y/n)"
    read response
    if [[ 'y' == "${response}" ]]; then
      jabba install $expected_version
    else
      echo "Skipping java install ${expected_version}"
    fi
  elif [ "$jabbarc_java_version" != "$java_version" ]; then
    jabba use $expected_version
  fi
}

function load_jabba() {
  if ! command -v jabba > /dev/null; then
    [ -s "$HOME/.jabba/jabba.sh" ] && source "$HOME/.jabba/jabba.sh"

    if [ -z $(jabba alias default) ]; then
      jabba alias default $DEFAULT_JABBA_VERSION
    fi

    use_jabba_version
    add-zsh-hook chpwd use_jabba_version
  fi
}

function java_prompt() {
  if [[ -s deps.edn || -s .jabbarc ]]; then
    version=$(jabba current)
    if [ -n "$version" ]; then
      echo "java:$version"
    else
      echo "java:system"
    fi
  fi
}

function __autoload_jabba() {
  [[ ! -s deps.edn && ! -s .jabbarc ]] && return 0
  load_jabba
  add-zsh-hook -d precmd __autoload_jabba
}
add-zsh-hook precmd __autoload_jabba

