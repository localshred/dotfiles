#!/usr/bin/env zsh

alias airpods='btconnect "amor fati pods" && SwitchAudioSource -t output -s "amor fati pods"'
alias speakers='SwitchAudioSource -t output -s "Built-in Output"'
alias wanderer='btconnect "The Grey Wanderer" && SwitchAudioSource -t output -s "The Gray Wanderer"'
alias yeti='SwitchAudioSource -t output -s "Yeti Stereo Microphone"'

function audiodefaults() {
  SwitchAudioSource -t output -s "Built-in Output"
  SwitchAudioSource -t input -s "Built-in Microphone"
}

function audiosources() {
  echo "Input:"
  SwitchAudioSource -a -t input | awk -F\( '{print "\011",$1}'
  echo
  echo "Output:"
  SwitchAudioSource -a -t output | awk -F\( '{print "\011",$1}'
}
