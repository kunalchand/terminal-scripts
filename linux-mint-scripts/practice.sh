#!/bin/bash

# Set the script to exit immediately if any command fails
set -e

ROADMAP="https://neetcode.io/roadmap"
MYLEETCODENOTES="https://docs.google.com/spreadsheets/d/14xdtVdBHRXI2thUCdcIiq0E-C1gLPzHMGUZl31hw6gc/edit#gid=1336779853"
MYPRGRAMMINGLANGUAGESNOTES="https://github.com/kunalchand/my-programming-languages-notes"

# Launch browser in the background
setsid google-chrome $ROADMAP > /dev/null 2>&1 &
setsid google-chrome $MYLEETCODENOTES > /dev/null 2>&1 &
setsid google-chrome $MYPRGRAMMINGLANGUAGESNOTES > /dev/null 2>&1 &

cd /home/kunalchand/Desktop/Projects/Others/daily-leetcode-practice
code .

# Get the PID of the terminal
TERMINAL_PID=$(ps -o ppid= -p $$)

# Close the terminal
kill -9 "$TERMINAL_PID"
