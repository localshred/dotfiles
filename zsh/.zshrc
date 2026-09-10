export code=~/code
export dotfiles=$code/src/utils/dotfiles
[[ -d $code/src/utils/dotfiles_work ]] && export dotfiles_work=$code/src/utils/dotfiles_work

source "$dotfiles/zsh-lib/bootstrap.zsh"
