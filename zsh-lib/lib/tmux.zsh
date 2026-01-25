#!/usr/bin/env zsh

# tkeys - tmux list-keys with optional search
# Usage:
#   tkeys              # List all keys
#   tkeys bind         # Naive grep list-keys output for "bind"
#   tkeys -r           # Show only root key bindings
#   tkeys -p           # Show only prefix key bindings
#   tkeys -c           # Show only copy-mode key bindings
#   tkeys -i           # Show only copy-mode-vi key bindings
#   tkeys -k C         # Show only bindings for specific key "C"
#   tkeys -e "pat.*"   # Search with regex (ignored if -k given)

tkeys() {
    local search_term=""
    local mode_filter=""
    local use_extended_regex=false
    local key_specific=false

    # Parse arguments
    while [[ $# -gt 0 ]]; do
        case $1 in
        -r)
            mode_filter="-T root"
            shift
            ;;
        -p)
            mode_filter="-T prefix"
            shift
            ;;
        -c)
            mode_filter="-T copy-mode "
            shift
            ;;
        -i)
            mode_filter="-T copy-mode-vi"
            shift
            ;;
        -e)
            use_extended_regex=true
            shift
            ;;
        -k)
            key_specific=true
            shift
            ;;
        *)
            search_term="$1"
            shift
            ;;
        esac
    done

    # Build the pipeline dynamically based on options
    local cmd="tmux list-keys"

    # Add mode filter if specified
    if [[ -n "$mode_filter" ]]; then
        cmd="$cmd | grep -- '$mode_filter'"
    fi

    # Add search filter if specified
    if [[ -n "$search_term" ]]; then
        if [[ "$key_specific" == true ]]; then
            # Match specific key in the correct position after table name
            cmd="$cmd | grep -E -- 'bind-key.+(prefix|root|copy-mode|copy-mode-vi)\\s+${search_term}\\s+'"
        elif [[ "$use_extended_regex" == true ]]; then
            cmd="$cmd | grep -E -- '$search_term'"
        else
            cmd="$cmd | grep -- '$search_term'"
        fi
    fi

    # Add final pager
    cmd="$cmd | less -FRSX"

    # Execute the pipeline
    run_command "$cmd"
}
