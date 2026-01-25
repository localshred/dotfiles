#!/usr/bin/env zsh

autoload colors; colors;

function __bootstrap() {
  source $dotfiles/zsh/load/env.zsh
  source $dotfiles/zsh/load/path.zsh
  __load_brew
  __load_defaults

  __load_zsh_libs $dotfiles/zsh/lib
  __load_completion /usr/local/share/zsh-completions
  __load_correction

  __say_hello
}

function __load_defaults() {
  bindkey -e
  setopt auto_name_dirs
  setopt pushd_ignore_dups
  setopt prompt_subst
  setopt no_beep
  setopt auto_cd
  setopt multios
  setopt cdablevarS
  setopt transient_rprompt
  setopt extended_glob
  autoload -U url-quote-magic
  zle -N self-insert url-quote-magic
  autoload -U zmv
  autoload -Uz add-zsh-hook
  bindkey "^[m" copy-prev-shell-word
  HISTFILE=$HOME/.zsh_history
  HISTSIZE=10000
  SAVEHIST=10000
  setopt hist_ignore_dups
  setopt hist_reduce_blanks
  setopt share_history
  setopt append_history
  setopt hist_verify
  setopt inc_append_history
  setopt extended_history
  setopt hist_expire_dups_first
  setopt hist_ignore_space
}

function __load_brew() {
  # Homebrew shellenv
  # Set PATH, MANPATH, etc.
  if [[ -d /opt/homebrew ]]; then
    eval "$(/opt/homebrew/bin/brew shellenv)"
  else
    eval "$(brew shellenv)"
  fi
}

function __load_zsh_libs() {
  libs_dir=$1
  for lib in $(find $libs_dir -type f -iname '*.zsh' -maxdepth 1); do
    source $lib
  done
}

function __say_hello() {
  fortune -s | ponysay
}

function zshbootstrap() { vim $dotfiles/zsh/bootstrap.zsh }

__bootstrap
