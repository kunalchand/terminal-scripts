#!/bin/bash

# Set the script to exit immediately if any command fails
set -e

# Resest any light changes to default temperature 6500K
redshift -x
# Set the light to night temperature 3800K
redshift -O 3800
