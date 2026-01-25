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
.vim/autoload
.vim/bundle
.config/doom
"

files="
.aprc
.clojure
.default-npm-packages
.doom.d
.gemrc
.git_template
.gitconfig
.gitignore.global
.gnupg/pgp-agent.conf
.irbrc
.spacemacs
.tmux.conf
.vim/autoload
.vim/ftplugin
.vim/spell
.vimrc
.zshrc
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
  if ! command -v "$HOME/.config/emacs/bin/doom" &>/dev/null; then
    print_info "Installing Doom Emacs (https://github.com/doomemacs/doomemacs#install)..."
    run_command "git clone --depth 1 https://github.com/doomemacs/doomemacs $HOME/.config/emacs"
    run_command "$HOME/.config/emacs/bin/doom install"
  fi

  # Uncomment for older Macs that need better 24-bit color support
  # if [ ! -f $HOME/.terminfo ]; then
  #   print_info "Building xterm-24bit terminfo"
  #   /usr/bin/tic -x -o $HOME/.terminfo terminfo-24bit.src
  # fi
}

install_brew() {
  if ! command -v brew &>/dev/null; then
    print_info "Installing XCode command line tools..."
    run_command "xcode-select --install"
    print_info "Installing brew..."
    run_command '/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"'
    if [[ -d /opt/homebrew ]]; then
      eval "$(/opt/homebrew/bin/brew shellenv)"
    else
      eval "$(brew shellenv)"
    fi
  fi

  print_info "Installing from Brewfile..."
  brew bundle install --file "$dotfiles/Brewfile"
}

install_vim_bundles() {
  if [[ ! -d $HOME/.config/nvim ]]; then
    print_info "Linking neovim config"
    run_command "ln -s $dotfiles/.vim/ $HOME/.config/nvim"
  fi

  print_info "Installing vim bundles"
  for repo_url in $(awk '{print $2}' "$dotfiles/data/vim-plugins.txt"); do
    repo_name=$(echo "$repo_url" | awk -F/ '{print ($NF)}' | sed 's/\.git$//')
    if [ -d "$HOME/.vim/bundle/$repo_name" ]; then
      print_info "Pulling latest $repo_name from $repo_url..."
      run_command "pushd $HOME/.vim/bundle/$repo_name > /dev/null"
      run_command "git pull"
      run_command "popd > /dev/null"
    else
      print_info "Cloning $repo_name from $repo_url..."
      run_command "git clone $repo_url $HOME/.vim/bundle/$repo_name"
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
files) install_files ;;
dirs) install_dirs ;;
vim) install_vim_bundles ;;
brew) install_brew ;;
other) install_non_brew_libs ;;
*) install ;;
esac
