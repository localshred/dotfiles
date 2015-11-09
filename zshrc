export utilities=/code/src/utilities
export mydotfiles=$utilities/mydotfiles
export PATH=/usr/local/bin:/usr/local/sbin:/usr/bin:/bin:/usr/sbin:/sbin:/usr/X11/bin:/usr/local/heroku/bin:/code/src/utilities/nuvidotfiles/bin
export UNIXNUVIS=/code/src/services/nuvis
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

source $mydotfiles/zsh/aliases.zsh
source $mydotfiles/zsh/functions.zsh
source $mydotfiles/zsh/git.zsh
source $mydotfiles/zsh/functions/minaret.zsh
source $utilities/nuvidotfiles/nuvi.sh
source $UNIXNUVIS/scripts/bash/buildx

cdpath=(~ ~/Documents ~/Desktop /code /code/src /code/src/services /code/src/gems /code/src/apps /code/src/utilities /code/src/sites /code/learn)

PROMPT='$(git_prompt_info)%(?,,%{${fg_bold[white]}%}[%?]%{$reset_color%} )%{$fg[magenta]%}%#%{$reset_color%} '
RPROMPT='%{$fg[green]%}%~%{$reset_color%} %{$fg[red]%}$(ruby_version)%{$reset_color%}'

ZSH_THEME_GIT_PROMPT_PREFIX="%{$fg[blue]%}["
ZSH_THEME_GIT_PROMPT_SUFFIX="%{$reset_color%} "
ZSH_THEME_GIT_PROMPT_DIRTY="%{$fg[blue]%}]%{$fg[red]%}💥 %{$reset_color%}"
ZSH_THEME_GIT_PROMPT_CLEAN="%{$fg[blue]%}]"

source ~/perl5/perlbrew/etc/bashrc

PERL_MB_OPT="--install_base \"/Users/bj/perl5\""; export PERL_MB_OPT;
PERL_MM_OPT="INSTALL_BASE=/Users/bj/perl5"; export PERL_MM_OPT;

### Added by the Heroku Toolbelt
export PATH="/usr/local/heroku/bin:$PATH"
