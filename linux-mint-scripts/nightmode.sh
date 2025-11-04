#!/bin/bash

# Set the script to exit immediately if any command fails
set -e

# Reset any light changes to default temperature 6500K
redshift -x

# Default Night Temperature = 3500K
DEFAULT_TEMPERATURE=3500

# Check if a parameter was passed and if it's a numeric value within the range 2000 and 4000
if [ "$#" -eq 1 ] && [[ $1 =~ ^[0-9]+$ ]] && (( $1 >= 2000 && $1 <= 4000 )); then
   # Set the light to the passed temperature
   redshift -O $1
else
   # Set the light to default night temperature
   redshift -O $DEFAULT_TEMPERATURE
fi

# Get the PID of the terminal
TERMINAL_PID=$(ps -o ppid= -p $$)

# Close the terminal
kill -9 "$TERMINAL_PID"

