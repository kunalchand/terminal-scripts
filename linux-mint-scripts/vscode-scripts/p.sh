#!/bin/bash

# Set the script to exit immediately if any command fails
set -e

cd /home/kunalchand/Desktop/Projects/Others/Random/pj

# Initialize the maximum file index to 0
max_index=0

# Loop through files that match the pattern "Test_*"
for file in Test_*; do
  # Check if the file name matches the expected pattern
  if [[ $file =~ Test_([0-9]+) ]]; then
    # Extract the number from the file name and compare it to max_index
    index="${BASH_REMATCH[1]}"
    if (( index > max_index )); then
      max_index=$index
    fi
  fi
done

# Increment the maximum index by 1 for the new file
let new_index=max_index+1

# Create a new file with the incremented index
new_file_name="Test_${new_index}.py"
touch "$new_file_name"

# Add specific content to the new file
cat <<EOF >> "$new_file_name"
import bisect
import copy
import heapq
import math
import random
from bisect import bisect, bisect_left, bisect_right, insort, insort_left, insort_right
from collections import Counter, defaultdict, deque
from copy import deepcopy
from dataclasses import dataclass
from functools import cache, cmp_to_key, lru_cache, reduce
from heapq import heapify, heappop, heappush, heappushpop
from itertools import combinations, pairwise, permutations, zip_longest
from math import ceil, factorial, floor, inf, sqrt
from typing import Deque, Dict, List, Optional, Set, Tuple, Union
EOF

# Open VSCode with the current directory and focus on the new file at the last line with the cursor at the end
code -n . -g "$new_file_name":$(( $(wc -l < "$new_file_name") + 1 ))

# Get the PID of the terminal
TERMINAL_PID=$(ps -o ppid= -p $$)

# Close the terminal
kill -9 "$TERMINAL_PID"
