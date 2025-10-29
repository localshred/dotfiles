#!/usr/bin/env zsh

alias ..='cd ..'
alias ...='cd ../..'
alias ag="ag -p $DOTFILES/.agignore"
alias history='fc -l 1'
alias la='ls -lAh'
alias ll='ls -l'
alias lst="ls -R | grep ":$" | sed -e 's/:$//' -e 's/[^-][^\/]*\//--/g' -e 's/^/ /' -e 's/-/|/'"
alias slack='killall Slack;sleep 3;open /Applications/Slack.app --args --force-color-profile=srgb'

alias tree1='tree -L 1'
alias tree2='tree -L 2'
alias tree3='tree -L 3'

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

extract() {
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

function jwtdecode() {
  jwt decode -j $(echo $1 | egrep -o "eyJhb[^/]+")
}

keyslow() {
  defaults write -g InitialKeyRepeat -int 225
  defaults write -g KeyRepeat -int 30
}

keyfast() {
  defaults write -g InitialKeyRepeat -int 10
  defaults write -g KeyRepeat -int 1
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
    [[ -n $1 ]] && echo "Setting volume to $1" && osascript -e "set volume output volume $1"
    echo "Volume: $(osascript -e "output volume of (get volume settings)")"
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

# Find fuzzy name of a file in current tree
function searchf() {
  find . -type f -iname "*$@*"
}

# Find fuzzy name of a directory in current tree
function searchd() {
  find . -type d -iname "*$@*"
}

# Show list of files in directory sorted by human readable size
# Optionally specify a recurse depth (default=1 (current dir))
function bigfiles() {
  local depth=${1:-1}
  du -h -d $depth | sort -h
}


color_blue='\033[0;36m'
color_orange='\033[0;35m'
color_red='\033[0;31m'
color_green='\033[0;32m'
color_yellow='\033[0;33m'
color_reset='\033[0;39m'

print_error() {
  echo -e "${color_red}!!> $*${color_reset}"
}

print_info() {
  echo -e "${color_blue}==> $*${color_reset}"
}

print_success() {
  echo -e "${color_green}==> $*${color_reset}"
}

print_command() {
  echo -e "${color_orange}-> $*${color_reset}"
}

print_warn() {
  echo -e "${color_yellow}~~> $*${color_reset}"
}

run_command() {
  local command=$@
  print_command "$command"
  eval "$command"
}