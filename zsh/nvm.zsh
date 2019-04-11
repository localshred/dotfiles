function load_nvm() {
  [[ ! -d node_modules ]] && return 0

  if ! command -v nvm > /dev/null; then
    export NVM_DIR="/Users/bj/.nvm"
    [ -s "$NVM_DIR/nvm.sh" ] && source "$NVM_DIR/nvm.sh"  # This loads nvm

    load-nvmrc() {
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
    add-zsh-hook chpwd load-nvmrc
    load-nvmrc
  fi
}
add-zsh-hook precmd load_nvm
