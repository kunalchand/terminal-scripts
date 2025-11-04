#!/bin/bash

# Set the script to exit immediately if any command fails
set -e

# Get the directory of the current script
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"

# Define an associative array to map commands to websites
declare -A COMMAND_TO_WEBSITE

# Read the edge_commands.txt file and populate the associative array
while IFS=':' read -r command url
do
   COMMAND_TO_WEBSITE["$command"]="$url"
done < "$SCRIPT_DIR/edge_commands.txt"

if [ -z "$1" ]; then
    # If no parameter is passed, open Microsoft Edge
    setsid microsoft-edge > /dev/null 2>&1 &
    
    # Get the PID of the terminal
    TERMINAL_PID=$(ps -o ppid= -p $$)

    # Close the terminal
    kill -9 "$TERMINAL_PID"
else
    # Get the command that was passed as a parameter to the script
    COMMAND=$1

    # Use the associative array to determine the website
    WEBSITE=${COMMAND_TO_WEBSITE[$COMMAND]}

    # Launch browser in the background
    setsid microsoft-edge $WEBSITE > /dev/null 2>&1 &

    # Get the PID of the terminal
    TERMINAL_PID=$(ps -o ppid= -p $$)

    # Close the terminal
    kill -9 "$TERMINAL_PID"
fi