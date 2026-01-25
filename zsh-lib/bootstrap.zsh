#!/usr/bin/env zsh

autoload -Uz colors && colors

__bootstrap() {
  source "$dotfiles/zsh-lib/load/env.zsh"
  source "$dotfiles/zsh-lib/load/path.zsh"
  __load_brew
  __load_defaults
  __load_zsh_libs "$dotfiles/zsh-lib/lib"
  __load_work_dotfiles
  __load_completion /usr/local/share/zsh-completions
  __load_correction
  __load_syntax_highlighting

  __say_hello
}

__load_defaults() {
  bindkey -e
  setopt auto_name_dirs
  setopt pushd_ignore_dups
  setopt prompt_subst
  setopt no_beep
  setopt auto_cd
  setopt multios
  setopt cdablevars
  setopt transient_rprompt
  setopt extended_glob
  autoload -U url-quote-magic
  zle -N self-insert url-quote-magic
  autoload -U zmv
  autoload -Uz add-zsh-hook
  bindkey "^[m" copy-prev-shell-word
  HISTFILE=$HOME/.zsh_history
  HISTSIZE=100000
  export SAVEHIST=100000
  setopt append_history
  setopt extended_history
  setopt hist_expire_dups_first
  setopt hist_find_no_dups
  setopt hist_ignore_dups
  setopt hist_ignore_space
  setopt hist_reduce_blanks
  setopt hist_save_no_dups
  setopt hist_verify
  setopt inc_append_history
  setopt interactive_comments
  setopt glob_dots
  setopt share_history
}

__load_brew() {
  # Homebrew shellenv
  # Set PATH, MANPATH, etc.
  if [[ -d /opt/homebrew ]]; then
    eval "$(/opt/homebrew/bin/brew shellenv)"
  else
    eval "$(brew shellenv)"
  fi
}

__load_work_dotfiles() {
  [[ -z "$dotfiles_work" ]] && return
  [[ ! -d "$dotfiles_work" ]] && return

  if [[ -f "$dotfiles_work/env.zsh" ]]; then
    source "$dotfiles_work/env.zsh"
  fi

  if [[ -d "$dotfiles_work/zsh/lib" ]]; then
    __load_zsh_libs "$dotfiles_work/zsh/lib"
  fi
}

__load_zsh_libs() {
  local libs_dir=$1
  local lib
  for lib in "$libs_dir"/*.zsh; do
    source "$lib"
  done
}

__load_syntax_highlighting() {
  local hl="$HOMEBREW_PREFIX/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh"
  [[ -f "$hl" ]] && source "$hl"
}

__say_hello() {
  fortune -s | ponysay
}

zshbootstrap() {
  vim "$dotfiles/zsh-lib/bootstrap.zsh"
}

__bootstrap
