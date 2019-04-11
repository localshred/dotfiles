supported_language_prompts=(js elixir go ruby)
function get_language_prompt() {
  for language in $supported_language_prompts; do
    prompt_function="${language}_prompt"
    if command -v $prompt_function > /dev/null; then
      language_prompt=$(eval "${language}_prompt")
      if [[ ! -z $language_prompt ]]; then
        echo " %{$fg[red]%}${language_prompt}%{$reset_color%}"
      fi
    fi
  done
}

PROMPT='$(git_prompt_info)%(?,,%{${fg_bold[white]}%}[%?]%{$reset_color%} )%{$fg[magenta]%}%#%{$reset_color%} '
RPROMPT='%{$fg[green]%}%~%{$reset_color%}$(get_language_prompt)'

ZSH_THEME_GIT_PROMPT_PREFIX="%{$fg[blue]%}["
ZSH_THEME_GIT_PROMPT_SUFFIX="%{$reset_color%} "
ZSH_THEME_GIT_PROMPT_DIRTY="%{$fg[blue]%}]%{$fg[red]%}💥 %{$reset_color%}"
ZSH_THEME_GIT_PROMPT_CLEAN="%{$fg[blue]%}]"
