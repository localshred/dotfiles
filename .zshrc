export GOPATH=/code/src/go
export GOBIN=/code/src/go/bin
export GOVERSION=$(go version | awk -Fgo '{print $3}' | awk '{print $1}')
export utilities=/code/src/utilities
export mydotfiles=$utilities/mydotfiles
export VISIONBOARD=~/Dropbox/BJ/vision/vision.md
export ECTO_EDITOR=nvim
export EDITOR=nvim
export REACT_EDITOR=nvim
export JAVA_HOME=$(/usr/libexec/java_home)

PATH=/usr/local/bin
PATH=$PATH:/usr/local/sbin
PATH=$PATH:/usr/bin
PATH=$PATH:/bin
PATH=$PATH:/usr/sbin
PATH=$PATH:/sbin
PATH=$PATH:/usr/X11/bin
PATH=$PATH:/code/src/utilities/ephemer/bin
PATH=$PATH:/Users/bj/Library/Python/3.7/bin
PATH=$PATH:/Users/bj/node_modules/.bin
PATH=$PATH:$HOME/.yarn/bin
PATH=$PATH:/usr/local/opt/go/libexec/bin
PATH=$PATH:$(go env GOPATH)/bin
PATH=$PATH:/Users/bj/.pyenv/bin
export PATH

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

cdpath=(~ ~/Documents ~/Desktop /code /code/src /code/src/utilities /code/src/go/src/github.com /code/src/go/src/gitlab.com)

fortune | ponysay
