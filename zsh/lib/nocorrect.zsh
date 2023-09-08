#!/usr/bin/env zsh

local programs=(asdf bundle cake clj-kondo curl erl lessc lunchy make man mkdir mv mysql rake sb task terraform yarn)

__load_correction() {
    setopt correct_all
    for program in $programs; do
      eval "alias $program='nocorrect $program'"
    done
    SPROMPT="zsh: correct $fg[red]%R$reset_color to $fg[green]%r$reset_color [nyae]? "
}

