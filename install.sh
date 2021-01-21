#!/usr/bin/env bash

color_orange='\033[0;35m'
color_red='\033[0;31m'
color_green='\033[0;32m'
color_yellow='\033[0;33m'
color_reset='\033[0;39m'

dotfiles="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

dirs="
.config/nvim
.gnupg
.nvm
.vim
.vim/bundle
"

files="
.clojure
.config/nvim/init.vim
.doom.d
.git_template
.gitconfig
.gitignore.global
.gnupg/pgp-agent.conf
.spacemacs
.tmux.conf
.vim/autoload
.vim/ftplugin
.vim/init.vim
.vim/spell
.vimrc
.zshrc
"

brew_kegs="
homebrew/cask-fonts
heroku/brew
mike-engel/jwt-cli
"

brew_casks="
1password
1password-cli
adoptopenjdk
dash
docker
font-fira-code
github
gpg-suite
insomnia
kindle
licecap
omnifocus
java
keybase
reactotron
zoomus
"

brew_bottles="
awscli
awslogs
candid82/brew/joker
clj-kondo
cloc
clojure
cmake
colordiff
coreutils
ctags
curl-openssl
dep
diff-so-fancy
direnv
elixir
emacs
exercism
fd
fortune
glib
gnupg
gnutls
heroku
htop-osx
heroku/brew
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
nvm
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
rbenv
readline
ripgrep
rlwrap
ruby-build
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
prettier
stylelint
"

print_error() {
  echo -e "${color_red}!!> $@${color_reset}"
}

print_info() {
  echo -e "${color_green}==> $@${color_reset}"
}

print_command() {
  echo -e "${color_orange}-> $@${color_reset}"
}

print_warn() {
  echo -e "${color_yellow}~~> $@${color_reset}"
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
  install_crontab
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
  print_info "Installing Spacemacs (https://www.spacemacs.org/#)..."
  if [ ! -d ~/.emacs.d ]; then
    run_command "git clone https://github.com/syl20bnr/spacemacs ~/.emacs.d"
  else
    print_info "Already installed"
  fi

  print_info "Installing Kiex (https://github.com/taylor/kiex)..."
  if [ ! -d "$HOME/.kiex" ]; then
    run_command "curl -sSL https://raw.githubusercontent.com/taylor/kiex/master/install | bash -s"
  else
    print_info "Already installed"
  fi

  print_info "Installing Jabba (https://github.com/shyiko/jabba)..."
  if [ ! -d "$HOME/.jabba" ]; then
    run_command "curl -sL https://github.com/shyiko/jabba/raw/master/install.sh | bash && . ~/.jabba/jabba.sh"
  else
    print_info "Already installed"
  fi

  print_info "Installing Babashka (https://github.com/borkdude/babashka)..."
  if ! hash bb 2>/dev/null; then
    run_command "bash <(curl -s https://raw.githubusercontent.com/borkdude/babashka/master/install)"
  fi
}

install_crontab() {
  print_info "Installing crontab..."
  run_command "sudo crontab -u $(whoami) $DOTFILES/crontab.cron"
  run_command "crontab -l"
}

install_brew() {
  if ! hash brew 2>/dev/null; then
    print_info "Installing command XCode line tools..."
    run_command "xcode-select --install"
    print_info "Installing brew..."
    run_command '/usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"'
  fi

  print_info "Tapping kegs..."
  run_command "brew tap $brew_kegs"

  print_info "Installing casks..."
  run_command "brew cask install $brew_casks"

  print_info "Installing bottles..."
  run_command "brew install $brew_bottles"
}

install_vim_bundles() {
  print_info "Installing vim bundles"
  for repo_url in $(awk '{print $2}' "$DOTFILES/data/vim-plugins.txt" ); do
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

