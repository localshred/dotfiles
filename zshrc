# Path to your oh-my-zsh configuration.
ZSH=$HOME/.oh-my-zsh

# Set name of the theme to load.
# Look in ~/.oh-my-zsh/themes/
# Optionally, if you set this to "random", it'll load a random theme each
# time that oh-my-zsh is loaded.
ZSH_THEME="localshred"

# Set to this to use case-sensitive completion
# CASE_SENSITIVE="true"

# Comment this out to disable weekly auto-update checks
# DISABLE_AUTO_UPDATE="true"

# Uncomment following line if you want to disable colors in ls
# DISABLE_LS_COLORS="true"

# Uncomment following line if you want to disable autosetting terminal title.
# DISABLE_AUTO_TITLE="true"

# Uncomment following line if you want red dots to be displayed while waiting for completion
# COMPLETION_WAITING_DOTS="true"

# Which plugins would you like to load? (plugins can be found in ~/.oh-my-zsh/plugins/*)
# Example format: plugins=(rails git textmate ruby lighthouse)
plugins=(git brew ruby rails3 rake)

source $ZSH/oh-my-zsh.sh
source /usr/local/share/zsh/site-functions/_hub # hub autocompletion

# Customize to your needs...
export PATH=/usr/local/bin:/usr/local/sbin:/usr/bin:/bin:/usr/sbin:/sbin:/usr/X11/bin:/Users/bj/.rvm/bin:/usr/local/lib/node_modules:/Applications/Adobe\ Flash\ Builder\ 4.6/sdks/4.0.0/bin:$HOME/.rvm/bin:/usr/local/heroku/bin
export NODE_PATH=/usr/local/lib/node_modules:./node_modules
export EDITOR=vim
export SSL_CERT_FILE=/usr/local/opt/curl-ca-bundle/share/ca-bundle.crt

cdpath=(~ ~/Documents ~/Desktop /code /code/src /code/src/services /code/src/gems /code/src/apps /code/src/utilities /code/src/sites /code/learn)

[[ -s "/Users/bj/.rvm/scripts/rvm" ]] && source "/Users/bj/.rvm/scripts/rvm"

