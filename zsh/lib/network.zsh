#!/usr/bin/env zsh

listeners() {
    port=$1
    lsof -t -i :$port
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
