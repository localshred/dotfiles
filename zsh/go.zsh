alias gopath="cd $GOPATH"
alias gosrc="cd $GOPATH/src"

function gohub() {
  cd $GOPATH/src/github.com/$1
}

function golab() {
  cd $GOPATH/src/gitlab.com/$1
}
