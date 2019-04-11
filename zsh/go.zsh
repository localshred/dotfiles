alias gopath="cd $GOPATH"
alias gosrc="cd $GOPATH/src"

function gohub() {
  cd $GOPATH/src/github.com/$1
}

function golab() {
  cd $GOPATH/src/gitlab.com/$1
}

function go_prompt() {
  if [[ ! -z $(find . -name '*.go' -type f -maxdepth 2) ]]; then
    version=$(go version | awk -Fgo '{print $3}' | awk '{print $1}')
    echo "go:$version"
  fi
}
