#!/usr/bin/env zsh

function audioin() {
  SwitchAudioSource -a -t input -s "$1"
}

function audioout() {
  SwitchAudioSource -a -t output -s "$1"
}

function audiosources() {
  echo "In:  $(SwitchAudioSource -c -t input)"
  echo "Out: $(SwitchAudioSource -c -t output)"
}

# outputs
alias speakers='audioout "MacBook Pro Speakers"'
alias yetiout='audioout "Yeti Stereo Microphone"'

# bt outputs
alias airpods='btconnect "bobbie" && audioout "bobbie"'
alias wanderer='btconnect "The Grey Wanderer" && audioout "The Gray Wanderer"'
alias pyle='btconnect pyle && audioout "Pyle"'

# inputs
alias yetiin='audioin "Yeti Stereo Microphone"'

function audiodefaults() {
  speakers
  audioin "MacBook Pro Microphone"
}