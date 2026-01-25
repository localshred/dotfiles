alias emacsalive='emacsclient -e "(+ 1 1)"'
em() {
    # Check if emacs server is running
    if ! emacsalive &>/dev/null; then
        echo "Starting Emacs server..."
        /opt/homebrew/bin/emacs --bg-daemon
        # Wait a moment for the server to start
        sleep 1
    fi

    emacsclient -nw -r -a /opt/homebrew/bin/emacs "$@"
}

emacsq() {
    # Only kill the server if it's actually running
    echo "Stopping Emacs server..."
    if emacsalive &>/dev/null; then
        emacsclient -e "(kill-emacs)"
    fi
    echo "Done"
}
