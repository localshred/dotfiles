#!/usr/bin/env zsh

alias speedtest='networkQuality -v'

listeners() {
    port=$1
    pid=$(lsof -t -i :$port)
    ps aux | grep "$pid"
}

portkill() {
    port=$1
    pid=$(lsof -t -i :$port)
    if [[ $pid -gt 0 ]]; then
        echo "Killing $pid"
        kill -9 $pid
    else
        echo "Won't kill pid $pid"
    fi
}
