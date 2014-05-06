export dotfiles=/code/src/utilities/dotfiles

source $dotfiles/zshuery/zshuery.sh
source $dotfiles/zsh/git.zsh
source $dotfiles/zsh/aliases.zsh
source $dotfiles/zsh/functions.zsh

load_defaults
load_aliases
load_completion $dotfiles/zshuery/completion
load_correction

export EDITOR=vim
export NODE_PATH=/usr/local/lib/node_modules:./node_modules
export PATH=/usr/local/bin:/usr/local/sbin:/usr/bin:/bin:/usr/sbin:/sbin:/usr/X11/bin:/usr/local/heroku/bin

cdpath=(~ ~/Documents ~/Desktop /code /code/src /code/src/services /code/src/gems /code/src/apps /code/src/utilities /code/src/sites /code/learn)

PROMPT='$(git_prompt_info)%(?,,%{${fg_bold[white]}%}[%?]%{$reset_color%} )%{$fg[magenta]%}%#%{$reset_color%} '
RPROMPT='%{$fg[green]%}%~%{$reset_color%} %{$fg[red]%}$(ruby_version)%{$reset_color%}'

ZSH_THEME_GIT_PROMPT_PREFIX="%{$fg[blue]%}["
ZSH_THEME_GIT_PROMPT_SUFFIX="%{$reset_color%} "
ZSH_THEME_GIT_PROMPT_DIRTY="%{$fg[blue]%}]%{$fg[red]%} ☭%{$reset_color%}"
ZSH_THEME_GIT_PROMPT_CLEAN="%{$fg[blue]%}]"

if which rbenv > /dev/null; then eval "$(rbenv init -)"; fi
