#!/usr/bin/env zsh

pathadd() { PATH="$PATH:${1}"; }
pathedit() { emc "$dotfiles/zsh/load/path.zsh"; }
pathrebuild() { source "$dotfiles/zsh/load/path.zsh"; }

# Define path directories in order of priority
path_dirs=(
  "$dotfiles/bin"
  "$HOME/bin"
  "$code/src/utilities/shred/bin"
  "$HOME/.config/emacs/bin"
  "$HOME/.local/bin"
  "$HOME/.yarn/bin"
  "$code/src/spiff/yak/bin"
  "$GOBIN"
  /usr/local/bin
  /usr/bin
  /usr/sbin
  /bin
  /sbin
  /Library/TeX/texbin
)

# Build PATH by joining array elements with colons
PATH=$(printf "%s:" "${path_dirs[@]}")
PATH=${PATH%:} # Remove trailing colon

# Add conditional paths
if [[ -d "$ANDROID_HOME" ]]; then
  PATH=$PATH:$ANDROID_HOME/emulator:$ANDROID_HOME/platform-tools
fi

export PATH
