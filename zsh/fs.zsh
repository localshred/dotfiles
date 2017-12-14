alias ...='cd ../..'
alias history='fc -l 1' # show history
alias la='ls -lA'
alias ll='ls -l'
alias lsa='ls -lah'
alias vim=/usr/local/bin/vim

function dash()
{
  open "dash://$@"
}

function hgrep()
{
  history | grep $@
}

function pbc()
{
  cat $@ | pbcopy
}

function psgrep()
{
  ps aux | grep $@
}

function recent() {
  period=${1:-15m}
  find . -type f -mtime -$period | grep -v '\.git'
}

function take() {
  mkdir -p $1
  cd $1
}

function diff {
  colordiff -u "$@" | less -RF
}
