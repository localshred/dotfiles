#!/usr/bin/env zsh

has_brew() { [[ -n ${commands[brew]} ]] }

__load_completion() {
    # http://www.reddit.com/r/commandline/comments/kbeoe/you_can_make_readline_and_bash_much_more_user/
    # https://wiki.archlinux.org/index.php/Zsh
    autoload -U compinit
    fpath=($* $fpath)
    fignore=(.DS_Store $fignore)
    # Brew completions
    if type brew &>/dev/null; then
      fpath=($fpath $(brew --prefix)/share/zsh/site-functions)
    fi
    compinit -i
    zmodload -i zsh/complist
    setopt complete_in_word
    setopt auto_remove_slash
    unsetopt always_to_end
    has_brew && compctl -K _gimme gimme
    [[ -f ~/.ssh/known_hosts ]] && hosts=(`awk '{print $1}' ~/.ssh/known_hosts | tr ',' '\n' `)
    [[ -f ~/.ssh/config ]] && hosts=($hosts `grep '^Host' ~/.ssh/config | sed s/Host\ // | egrep -v '^\*$'`)
    [[ -f /var/lib/misc/ssh_known_hosts ]] && hosts=($hosts `awk -F "[, ]" '{print $1}' /var/lib/misc/ssh_known_hosts | sort -u`)
    zstyle ':completion:*' insert-tab pending
    zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}' 'r:|[._-]=* r:|=*' 'l:|=* r:|=*'
    highlights='${PREFIX:+=(#bi)($PREFIX:t)(?)*==31=1;32}':${(s.:.)LS_COLORS}}
    highlights2='=(#bi) #([0-9]#) #([^ ]#) #([^ ]#) ##*($PREFIX)*==1;31=1;35=1;33=1;32=}'
    zstyle -e ':completion:*' list-colors 'if [[ $words[1] != kill && $words[1] != strace ]]; then reply=( "'$highlights'" ); else reply=( "'$highlights2'" ); fi'
    unset highlights
    zstyle ':completion:*' completer _complete _match _approximate
    zstyle ':completion:*' squeeze-slashes true
    zstyle ':completion:*' expand 'yes'
    zstyle ':completion:*:match:*' original only
    zstyle ':completion:*:approximate:*' max-errors 1 numeric
    zstyle ':completion:*:hosts' hosts $hosts
    zstyle ':completion::complete:*' use-cache 1
    zstyle ':completion::complete:*' cache-path ./cache/
    zstyle ':completion:*:cd:*' ignore-parents parent pwd
    zstyle ':completion:*:mpg321:*' file-patterns '*.(mp3|MP3):mp3\ files *(-/):directories'
    zstyle ':completion:*:ogg123:*' file-patterns '*.(ogg|OGG):ogg\ files *(-/):directories'
    zstyle ':completion:*:kill:*:processes' list-colors '=(#b) #([0-9]#) ([0-9a-z-]#)*=01;34=0=01'
    zstyle ':completion:*:*:*:processes' command "ps -u `whoami` -o pid,user,comm -w -w"

}

