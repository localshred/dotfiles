#!/usr/bin/env zsh

local programs=(man mv mysql mkdir erl curl rake make cake lessc lunchy sb)

__load_correction() {
    setopt correct_all
    for program in $programs; do
      eval "alias $program='nocorrect $program'"
    done
    SPROMPT="zsh: correct $fg[red]%R$reset_color to $fg[green]%r$reset_color [nyae]? "
    # alias man='nocorrect man'
    # alias mv='nocorrect mv'
    # alias mysql='nocorrect mysql'
    # alias mkdir='nocorrect mkdir'
    # alias erl='nocorrect erl'
    # alias curl='nocorrect curl'
    # alias rake='nocorrect rake'
    # alias make='nocorrect make'
    # alias cake='nocorrect cake'
    # alias lessc='nocorrect lessc'
    # alias lunchy='nocorrect lunchy'
    # alias sb='nocorrect sb'
}

