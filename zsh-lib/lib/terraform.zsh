function tfselect() {
  if [[ ! -f main.tf ]]; then
    echo "Couldn't find a main.tf in your current directory"
    return
  fi

  local version=$(grep required_version main.tf | awk -F\" '{print $2}')
  local has_version=$(tfenv list | grep $version)

  if [[ "$has_version" != "" ]]; then
    tfenv use $version
  else
    echo "You don't tf $version installed, do you want to install it? (y/n)"
    read response
    if [[ 'y' == "${response}" ]]; then
      tfenv install $version
      tfenv use $version
    else
      echo "Skipping tf $version install"
    fi
  fi
}
