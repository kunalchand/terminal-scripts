#!/bin/bash

# Set the script to exit immediately if any command fails
set -e

# Resest any light changes to default temperature 6500K
redshift -x

# Get the PID of the terminal
TERMINAL_PID=$(ps -o ppid= -p $$)

# Close the terminal
kill -9 "$TERMINAL_PID"