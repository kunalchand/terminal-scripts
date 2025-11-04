#!/bin/bash

cd "/home/kunalchand/Desktop/Projects/trulogik-company/trucasemanager-core-fe"

# Open VSCode in a new session which detaches it fromt the terminal and runs independently
setsid code . "$@" > /dev/null 2>&1 &

# Get the PID of the terminal
TERMINAL_PID=$(ps -o ppid= -p $$)

# Close the terminal
kill -9 "$TERMINAL_PID"
