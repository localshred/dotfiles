export utilities=/code/src/utilities
export mydotfiles=$utilities/mydotfiles
export PATH=/usr/local/bin:/usr/local/sbin:/usr/bin:/bin:/usr/sbin:/sbin:/usr/X11/bin:/code/src/utilities/ephemer/bin
export VISIONBOARD=~/Dropbox/BJ/vision/vision.md
export EDITOR=vim
export JAVA_HOME=$(/usr/libexec/java_home)

# Load zshuery
bindkey -e
source $mydotfiles/zshuery/zshuery.sh
load_defaults
load_aliases
load_completion /usr/local/share/zsh-completions
load_correction

# Load all aliases, functions
for function_file in $(find $mydotfiles/zsh -type f -iname '*.zsh')
do
  source $function_file
done

cdpath=(~ ~/Documents ~/Desktop /code /code/src /code/src/services /code/src/gems /code/src/apps /code/src/utilities /code/src/sites)

PROMPT='$(git_prompt_info)%(?,,%{${fg_bold[white]}%}[%?]%{$reset_color%} )%{$fg[magenta]%}%#%{$reset_color%} '
RPROMPT='%{$fg[green]%}%~%{$reset_color%} %{$fg[red]%}$(ruby_version)%{$reset_color%}'

ZSH_THEME_GIT_PROMPT_PREFIX="%{$fg[blue]%}["
ZSH_THEME_GIT_PROMPT_SUFFIX="%{$reset_color%} "
ZSH_THEME_GIT_PROMPT_DIRTY="%{$fg[blue]%}]%{$fg[red]%}💥 %{$reset_color%}"
ZSH_THEME_GIT_PROMPT_CLEAN="%{$fg[blue]%}]"

fortune | ponysay

export NVM_DIR="/Users/bj/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && source "$NVM_DIR/nvm.sh"  # This loads nvm

# place this after nvm initialization!
autoload -U add-zsh-hook
load-nvmrc() {
  local node_version="$(nvm version)"
  local nvmrc_path="$(nvm_find_nvmrc)"

  if [ -n "$nvmrc_path" ]; then
    local nvmrc_node_version=$(nvm version "$(cat "${nvmrc_path}")")

    if [ "$nvmrc_node_version" = "N/A" ]; then
      nvm install
    elif [ "$nvmrc_node_version" != "$node_version" ]; then
      nvm use
    fi
  elif [ "$node_version" != "$(nvm version default)" ]; then
    echo "Reverting to nvm default version"
    nvm use default
  fi
}
add-zsh-hook chpwd load-nvmrc
load-nvmrc

eval "$(rbenv init -)"
