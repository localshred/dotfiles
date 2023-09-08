#!/usr/bin/env bash

color_orange='\033[0;35m'
color_red='\033[0;31m'
color_green='\033[0;32m'
color_yellow='\033[0;33m'
color_reset='\033[0;39m'

dotfiles="$(cd "$(dirname "${BASH_SOURCE[0]}")" >/dev/null 2>&1 && pwd)"

dirs="
.gnupg
.vim
.vim/autload
.vim/bundle
"

files="
.clojure
.doom.d
.gemrc
.git_template
.gitconfig
.gitignore.global
.gnupg/pgp-agent.conf
.spacemacs
.tmux.conf
.vim/autoload
.vim/ftplugin
.vim/spell
.vimrc
.zshrc
"

# Taps
brew_kegs="
homebrew/cask-fonts
heroku/brew
mike-engel/jwt-cli
d12frosted/emacs-plus
"

brew_casks="
1password
1password-cli
alfred
brave-browser
dash
docker
dropbox
font-fira-code
github
gpg-suite
graalvm/tap/graalvm-ce-lts-java11
insomnia
iterm2
java
keybase
kindle
licecap
omnifocus
reactotron
signal
temurin
zoom
"

brew_bottles="
asdf
awscli
awslogs
babashka/brew/neil
blueutil
candid82/brew/joker
clj-kondo
cloc
clojure
clojure-lsp/brew/clojure-lsp-native
cmake
colordiff
coreutils
ctags
curl-openssl
dep
diff-so-fancy
difftastic
direnv
elixir
'emacs-plus@28 --with-native-comp --without-cocoa'
exercism
fd
fortune
git-delta
glib
gnupg
gnutls
heroku
htop-osx
hub
jpeg
jq
leiningen
libpng
libpq
libssh
libssh2
libtiff
jwt-cli
maven
ncurses
neovim
openldap
openssl
openssl@1.1
pcre
pcre2
pinentry-mac
ponysay
protobuf
python
python@2
readline
ripgrep
rlwrap
shellcheck
switchaudio-osx
task
telnet
tfenv
the_silver_searcher
tmux
tree
unixodbc
watchman
wget
wireshark
yarn
zsh
zsh-completions
"

npm_global_packages="
bash-language-server
prettier
stylelint
"

print_error() {
  echo -e "${color_red}!!> $*${color_reset}"
}

print_info() {
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

install() {
  install_dirs
  install_files
  install_brew
  install_vim_bundles
  # install_crontab
  install_non_brew_libs
  install_global_npm
}

install_dirs() {
  print_info "Ensuring dirs..."
  for dir in $dirs; do
    run_command "mkdir -p $HOME/$dir"
  done
}

install_files() {
  print_info "Linking files..."
  for file in $files; do
    if [[ (-d $dotfiles/$file && ! -d $HOME/$file) || ! -s $HOME/$file ]]; then
      run_command "ln -s $dotfiles/$file $HOME/$file"
    else
      print_warn "$HOME/$file exists, skipping"
    fi
  done
}

install_non_brew_libs() {
  if ! hash ~/.emacs.d/bin/doom 2>/dev/null; then
    print_info "Installing Doom Emacs (https://github.com/doomemacs/doomemacs#install)..."
    run_command "git clone --depth 1 https://github.com/doomemacs/doomemacs ~/.emacs.d
~/.emacs.d/bin/doom sync"
  fi

  if ! hash bb 2>/dev/null; then
    print_info "Installing Babashka (https://github.com/borkdude/babashka)..."
    run_command "bash <(curl -s https://raw.githubusercontent.com/borkdude/babashka/master/install)"
  fi

  if [ ! -f ~/.terminfo ]; then
    print_info "Building xterm-24 \$SHELL"
    /usr/bin/tic -x -o ~/.terminfo terminfo-24bit.src
  fi

  libdir="${HOME}/code/src/lib"
  dest="${libdir}/icons-in-terminal"
  if [ ! -d "${dest}" ]; then
    print_info "Installing sebastiencs/icons-in-terminal"
    run_command "mkdir -p ${libdir}"
    run_command "git clone https://github.com/sebastiencs/icons-in-terminal.git ${dest}"
    run_command "source ${dest}/install-autodetect.sh"
  fi
}

install_brew() {
  if ! hash brew 2>/dev/null; then
    print_info "Installing command XCode line tools..."
    run_command "xcode-select --install"
    print_info "Installing brew..."
    run_command '/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"'
    eval "$(/opt/homebrew/bin/brew shellenv)"
  fi

  print_info "Tapping kegs..."
  for keg in $brew_kegs; do
    run_command "brew tap $keg"
  done

  print_info "Installing casks..."
  for cask in $brew_casks; do
    run_command "brew install --cask $cask"
  done

  print_info "Installing bottles..."
  for bottle in $brew_bottles; do
    run_command "brew install $bottle"
  done
}

install_vim_bundles() {
  print_info "Linking neovim config"
  run_command "ln -s $dotfiles/.vim ~/.config/nvim"

  print_info "Installing vim bundles"
  for repo_url in $(awk '{print $2}' "$DOTFILES/data/vim-plugins.txt"); do
    repo_name=$(echo "$repo_url" | awk -F/ '{print ($NF)}' | sed 's/\.git$//')
    if [ -d "$HOME/.vim/bundle/$repo_name" ]; then
      print_info "Pulling latest $repo_name from $repo_url..."
      run_command "pushd ~/.vim/bundle/$repo_name > /dev/null"
      run_command "git pull"
      run_command "popd > /dev/null"
    else
      print_info "Cloning $repo_name from $repo_url..."
      run_command "git clone $repo_url ~/.vim/bundle/$repo_name"
    fi
  done
}

install_global_npm() {
  npm install -g "$npm_global_packages"
}

uninstall() {
  print_info "Uninstall..."
  for file in $files; do
    if [[ -L $HOME/$file ]]; then
      run_command "rm $HOME/$file"
    else
      print_warn "$HOME/$file missing, skipping"
    fi
  done
}

case "$1" in
  uninstall) uninstall ;;
  *) install ;;
esac
