function java_version {
  sdk current java | perl -p -e 's/\s*Using java version (.+)\s*/\1/' | sed '/^[[:space:]]*$/d'
}

# function use_sdkman_version {
#   [[ ! -s .sdkmanrc ]] && return 0
#   sdk env

#   local expected_version=$(cat .sdkmanrc | grep java= | awk -F= '{ print $2  }')
#   local sdkmanrc_java_version=$(jabba which $expected_version)

#   if [ -z "$sdkmanrc_java_version" ]; then
#     echo "You haven't installed java ${expected_version}. Do you want to? (y/n)"
#     read response
#     if [[ 'y' == "${response}" ]]; then
#       jabba install $expected_version
#     else
#       echo "Skipping java install ${expected_version}"
#     fi
#   elif [ "$sdkmanrc_java_version" != java_version ]; then
#     jabba use $expected_version
#   fi
# }

function load_jabba() {
  if ! command -v sdk > /dev/null; then
    [ -s "$HOME/.sdkman/bin/sdkman-init.sh" ] && source "$HOME/.sdkman/bin/sdkman-init.sh"

    # use_sdkman_version
    # add-zsh-hook chpwd use_sdkman_version
  fi
}

function clojure_prompt() {
  if [[ -s deps.edn || -s project.clj ]]; then
    if command -v clj > /dev/null; then
      version=$(clj --version | awk '{ print $4 }')
      if [ -n "$version" ]; then
        echo "clj:$version"
      fi
    fi
  fi
}

function java_prompt() {
  if [[ -s deps.edn || -s .sdkmanrc ]]; then
    version=$(java_version)
    if [ -n "$version" ]; then
      echo "java:$version"
    else
      echo "java:system"
    fi
  fi
}

function __autoload_jabba() {
  [[ ! -s deps.edn && ! -s .sdkmanrc ]] && return 0
  load_jabba
  add-zsh-hook -d precmd __autoload_jabba
}
add-zsh-hook precmd __autoload_jabba

