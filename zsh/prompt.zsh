function get_language_prompt() {
  lang=""
  version=""
  if [[ -d node_modules ]]; then
    lang="js"
    version=$(nvm current)
  elif [[ -f mix.exs ]]; then
    lang="elixir"
    if [[ -f .kiexrc ]]; then
      version=$(cat .kiexrc)
    fi
    if [[ -z "$version" ]]; then
      version=$(kiex list | grep "=\* elixir" | awk -F- '{print $2}')
    fi
    kiex use $version > /dev/null
  elif [[ ! -z $(find . -name '*.go' -type f -maxdepth 2) ]]; then
    lang="go"
    version=$(go version | awk -Fgo '{print $3}' | awk '{print $1}')
  elif [[ -s Gemfile ]]; then
    lang="ruby"
    version=$(rbenv version | awk '{print $1}')
  fi
  if [[ ! -z $lang && ! -z $version ]]; then
    echo " %{$fg[red]%}${lang}:${version}%{$reset_color%}"
  fi
}

PROMPT='$(git_prompt_info)%(?,,%{${fg_bold[white]}%}[%?]%{$reset_color%} )%{$fg[magenta]%}%#%{$reset_color%} '
RPROMPT='%{$fg[green]%}%~%{$reset_color%}$(get_language_prompt)'

ZSH_THEME_GIT_PROMPT_PREFIX="%{$fg[blue]%}["
ZSH_THEME_GIT_PROMPT_SUFFIX="%{$reset_color%} "
ZSH_THEME_GIT_PROMPT_DIRTY="%{$fg[blue]%}]%{$fg[red]%}💥 %{$reset_color%}"
ZSH_THEME_GIT_PROMPT_CLEAN="%{$fg[blue]%}]"
