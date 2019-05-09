function btconnect() {
  device=$1
  echo "Connecting $device..."
  script_dir=$(dirname $0)
  osascript $DOTFILES/zsh/lib/osascripts/connect_bluetooth.scpt $device
}
