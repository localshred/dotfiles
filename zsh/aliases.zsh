# Use homebrew vim with clipboard support
alias vim=/usr/local/bin/vim

# Push and pop directories on directory stack
alias pu='pushd'
alias po='popd'

# Basic directory operations
alias ...='cd ../..'
alias -- -='cd -'

# Super user
alias _='sudo'
alias please='sudo'

#alias g='grep -in'

# Show history
alias history='fc -l 1'

# Single character aliases
alias a='ack'
alias b='bundle'
alias g='git'
alias s='PB_IGNORE_DEPRECATIONS=1 RAILS_ENV=test bx rake spec'
alias r='noglob rake'
alias v='vim'
alias ri='noglob ri'

# List directory contents
alias lsa='ls -lah'
alias ll='ls -l'
alias la='ls -lA'
alias sl='ls' # often screw this up

alias git='hub'
alias orb='irb'
alias gti='git'

alias afind='ack-grep -il'

alias pg='psql -h localhost -U bj'
alias be='bundle exec'
alias bi='bundle install'
alias bis='bundle install --binstubs'
alias bx='bundle exec'
alias bo='bundle open'
alias bs='bundle show'
alias bu='bundle update'
alias rspec='nocorrect rspec'
alias foreman='nocorrect foreman'

alias sourcezsh='source ~/.zshrc'
alias vzsh='vim ~/.zshrc'

# Random
alias lunch="ruby -e 't=Time.now; m=((Time.new(t.year,t.month,t.day,12,0,0)-t)/60).ceil.to_s; puts \"Hunger Satisfied in #{m} minutes\"'"
alias eod="ruby -e 't=Time.now; m=((Time.new(t.year,t.month,t.day,18,0,0)-t)/60).ceil.to_s; puts \"Go home in #{m} minutes\"'"

alias railz='PB_CLIENT_TYPE=zmq PB_IGNORE_DEPRECATIONS=1 bin/rails s'
