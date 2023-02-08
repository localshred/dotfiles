function btpaired() {
  blueutil --paired
}

function btconnected() {
  blueutil --connected
}

function btdeviceid() {
  device_name="$1"
  btpaired | grep -i "$device_name" | awk '{print $2}' |sed 's/,//'
}

function btconnect() {
  device_name="$1"
  device_id=$(btdeviceid "$device_name")
  if [[ "$device_id"  ]]; then
    echo "Connecting bt device $device_name with id $device_id"
    blueutil --connect "$device_id"
  else
    echo "Can't find device named $device_name. Currently paired devices:"
    btpaired
  fi
}

function btdisconnect() {
  device_name="$1"
  device_id=$(btdeviceid "$device_name")
  if [[ "$device_id"  ]]; then
    echo "Disconnecting bt device $device_name with id $device_id. Switching to speakers"
    speakers
    blueutil --disconnect "$device_id"
  else
    echo "Can't find device named $device_name. Currently connected devices:"
    btconnected
  fi
}
