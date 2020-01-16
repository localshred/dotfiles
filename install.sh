#!/usr/bin/env bash

dotfiles=$(dirname "$0")

echo "LINKING..."
files_to_link=".zshrc .vimrc .gitconfig .gitignore .git_template .tmux.conf .vim/autoload .vim/ftplugin .vim/spell .spacemacs"
for file in $files_to_link; do
  if [[ ! -s $file ]]; then
    echo "LINK $file ~/$file"
    ln -s $dotfiles/$file ~/$file
  else
    echo "SKIP $file"
  fi
done

# TODO
# Install vim plugins
# Install brew formulae
# Install neovim (if not in brew)
# Install nvm (if not in brew)
# Install rbenv (if not in brew)
# Install kiex (if not in brew)
