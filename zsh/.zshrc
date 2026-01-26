export code=~/code
export dotfiles=$code/src/utils/dotfiles
if [[ -d $code/src/utils/dotfiles_work ]]; then
  export dotfiles_work=$code/src/utils/dotfiles_work
fi
source "$dotfiles/zsh-lib/bootstrap.zsh"

# Yak CLI
export PATH="./bin:$PATH"
