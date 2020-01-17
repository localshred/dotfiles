#!/usr/bin/env bash

dotfiles="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
dirs=".vim .vim/bundle"
files=".zshrc .vimrc .gitconfig .gitignore .git_template .tmux.conf .vim/autoload .vim/ftplugin .vim/spell .vim/init.vim .spacemacs"

install() {
	echo "Creating Dirs..."
	for dir in $dirs; do
		local command="mkdir -p $HOME/$dir"
		echo $command
		eval $command
	done

	echo "Linking..."
	for file in $files; do
		if [[ (-d $dotfiles/$file && ! -d $HOME/$file) || ! -s $HOME/$file ]]; then
			local command="ln -s $dotfiles/$file $HOME/$file"
			echo $command
			eval $command
		else
			echo "$HOME/$file exists, skipping"
		fi
	done

	install_brew
	install_vim_bundle

	# TODO
	# Install vim plugins
	# Install kiex (if not in brew)
}

install_brew() {
	brew tap homebrew/cask-fonts

	brew cask install adoptopenjdk font-fira-code insomnia java reactotron

	brew install awslogs clj-kondo cloc clojure cmake colordiff coreutils ctags dep diff-so-fancy curl-openssl direnv emacs exercism fortune glib gnupg gnutls gpgme htop-osx hub jabba jq jpeg leiningen libpng libpq libssh libssh2 libtiff maven ncurses neovim nvm openldap openssl openssl@1.1 pcre pcre2 ponysay protobuf python python@2 readline ripgrep rlwrap ruby-build rbenv switchaudio-osx task telnet terraform the_silver_searcher tmux tree unixodbc watchman wget wireshark yarn zsh zsh-completions 
}

install_vim_bundle() {
	pushd ~/.vim/bundle
	for repo_url in $(cat data/vim-plugins.txt | awk '{print $2}'); do
		git clone $repo_url
	done
	popd
}

uninstall() {
	echo "Uninstall..."
	for file in $files; do
		if [[ -L $HOME/$file ]]; then
			local command="rm $HOME/$file"
			echo $command
			eval $command
		else
			echo "$HOME/$file missing, skipping"
		fi
	done
}

case "$1" in
	uninstall) uninstall ;;
	*) install ;;
esac

