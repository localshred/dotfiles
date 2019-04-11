export GOROOT=/usr/local/Cellar/go/1.12.1/libexec
export GOPATH=/code/src/go
export GOBIN=/code/src/go/bin
export utilities=/code/src/utilities
export mydotfiles=$utilities/mydotfiles
export PATH=/usr/local/bin:/usr/local/sbin:/usr/bin:/bin:/usr/sbin:/sbin:/usr/X11/bin:/code/src/utilities/ephemer/bin:/Users/bj/Library/Python/3.7/bin:/Users/bj/node_modules/.bin:$HOME/.yarn/bin:/usr/local/opt/go/libexec/bin:$(go env GOPATH)/bin
export VISIONBOARD=~/Dropbox/BJ/vision/vision.md
export ECTO_EDITOR=vim
export EDITOR=vim
export REACT_EDITOR=vim
export JAVA_HOME=$(/usr/libexec/java_home)

# Load zshuery
bindkey -e
source $mydotfiles/zshuery/zshuery.sh
load_defaults
load_aliases
load_completion /usr/local/share/zsh-completions
load_correction

# Load all aliases, functions
autoload -Uz add-zsh-hook
for function_file in $(find $mydotfiles/zsh -type f -iname '*.zsh')
do
  source $function_file
done

cdpath=(~ ~/Documents ~/Desktop /code /code/src /code/src/services /code/src/modules /code/src/gems /code/src/apps /code/src/utilities /code/src/sites)

fortune | ponysay
