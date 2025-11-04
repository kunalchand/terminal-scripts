#!/bin/bash

# Restart WiFi (off then on)
nmcli radio wifi off
nmcli radio wifi on

# Get the PID of the terminal
TERMINAL_PID=$(ps -o ppid= -p $$)

# Close the terminal
kill -9 "$TERMINAL_PID"
