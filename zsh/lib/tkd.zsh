#!/usr/bin/env zsh

function tkdform() {
  ruby -e '
forms = [
  "Kibon",
  "Palgwe Il Jang",
  "Palgwe Ee Jang",
  "Palgwe Sam Jang",
  "Taeguk Il Jang",
  "Taeguk Ee Jang",
  "Taeguk Sam Jang",
]

puts forms.sample
'
}
