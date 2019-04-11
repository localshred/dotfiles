#!/usr/bin/env zsh

cdpath=(~ ~/Documents ~/Desktop /code /code/src /code/src/utilities /code/src/go/src/github.com /code/src/go/src/gitlab.com)

alias ..='cd ..'
alias ...='cd ../..'
alias ag="ag -p $DOTFILES/.agignore"
alias history='fc -l 1'
alias la='ls -lAh'
alias ll='ls -l'
alias lst="ls -R | grep ":$" | sed -e 's/:$//' -e 's/[^-][^\/]*\//--/g' -e 's/^/ /' -e 's/-/|/'"

function dash() {
  open "dash://$@"
}

function hgrep() {
  history | grep $@
}

function pbc() {
  cat $@ | pbcopy
}

function psgrep() {
  ps aux | grep $@
}

function recent() {
  period=${1:-15m}
  find . -type f -mtime -$period | grep -v '\.git/'
}

function take() {
  mkdir -p $1 && cd $1
}

function diff {
  colordiff -u "$@" | less -RF
}

ex() {
    if [[ -f $1 ]]; then
        case $1 in
          *.tar.bz2) tar xvjf $1;;
          *.tar.gz) tar xvzf $1;;
          *.tar.xz) tar xvJf $1;;
          *.tar.lzma) tar --lzma xvf $1;;
          *.bz2) bunzip $1;;
          *.rar) unrar $1;;
          *.gz) gunzip $1;;
          *.tar) tar xvf $1;;
          *.tbz2) tar xvjf $1;;
          *.tgz) tar xvzf $1;;
          *.zip) unzip $1;;
          *.Z) uncompress $1;;
          *.7z) 7z x $1;;
          *.dmg) hdiutul mount $1;; # mount OS X disk images
          *) echo "'$1' cannot be extracted via >ex<";;
    esac
    else
        echo "'$1' is not a valid file"
    fi
}
md5() { echo -n $1 | openssl md5 /dev/stdin }
md5file() { cat $1 | openssl md5 /dev/stdin }
sha1() { echo -n $1 | openssl sha1 /dev/stdin }
sha1file() { cat $1 | openssl sha1 /dev/stdin }
sha256() { echo -n $1 | openssl dgst -sha256 /dev/stdin }
sha256file() { cat $1 | openssl dgst -sha256 /dev/stdin }
sha512() { echo -n $1 | openssl dgst -sha512 /dev/stdin }
sha512file() { cat $1 | openssl dgst -sha512 /dev/stdin }
rot13() { echo $1 | tr "A-Za-z" "N-ZA-Mn-za-m" }
urlencode() { python -c "import sys, urllib as ul; print ul.quote_plus(sys.argv[1])" $1 }
urldecode() { python -c "import sys, urllib as ul; print ul.unquote_plus(sys.argv[1])" $1 }
path() {
  # Pretty-print $PATH
  echo $PATH | tr ":" "\n" | \
    awk "{ sub(\"/usr\",   \"$fg_no_bold[green]/usr$reset_color\"); \
           sub(\"/bin\",   \"$fg_no_bold[blue]/bin$reset_color\"); \
           sub(\"/opt\",   \"$fg_no_bold[cyan]/opt$reset_color\"); \
           sub(\"/sbin\",  \"$fg_no_bold[magenta]/sbin$reset_color\"); \
           sub(\"/local\", \"$fg_no_bold[yellow]/local$reset_color\"); \
           print }"
}

gimme() { brew install $1 }

_gimme() { reply=(`brew search`) }

pman() { man $1 -t | open -f -a Preview } # open man pages in Preview

vol() {
    if [[ -n $1 ]]; then osascript -e "set volume output volume $1"
    else osascript -e "output volume of (get volume settings)"
    fi
}

evernote() {
    if [[ -n $1 ]]; then msg=$1
    else msg=$(cat | sed -e 's/\\/\\\\/g' -e 's/\"/\\\"/g')
    fi
    osascript -e 'tell application "Evernote" to open note window with (create note with text "'$msg'")' -e 'tell application "Evernote" to activate'
}

quit() {
    for app in $*; do
        osascript -e 'quit app "'$app'"'
    done
}

relaunch() {
    for app in $*; do
        osascript -e 'quit app "'$app'"';
        sleep 2;
        open -a $app
    done
}

selected() {
  osascript <<EOT
    tell application "Finder"
      set theFiles to selection
      set theList to ""
      repeat with aFile in theFiles
        set theList to theList & POSIX path of (aFile as alias) & "\n"
      end repeat
      theList
    end tell
EOT
}
