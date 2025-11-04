#!/bin/bash

# The directory to check for Git repositories
TARGET_DIR="/home/kunalchand/Desktop/Projects"
TARGET_DIR2="/home/kunalchand/Documents/mint-scripts"

# ANSI color codes
REPO_COLOR='\033[1;31m'   # Red
FILE_COLOR='\033[0;96m'   # Cyan
PATH_COLOR='\033[0;33m'   # Yellow/Orange
NO_COLOR='\033[0m'        # No color

# Function to check the git status
check_git_status() {
    local dir=$1
    local repo_name=$(basename "$dir")
    pushd "$dir" > /dev/null

    # Function to print repo header once
    local printed_header=false
    print_header() {
        if [ "$printed_header" = false ]; then
            echo -e "${REPO_COLOR}$repo_name${NO_COLOR}  ${PATH_COLOR}$dir${NO_COLOR}"
            printed_header=true
        fi
    }

    # Check for unstaged changes
    local unstaged_changes=$(git status --porcelain)
    if [ -n "$unstaged_changes" ]; then
        print_header
        echo -e "  ↳ has unstaged changes"
        echo -e "${FILE_COLOR}${unstaged_changes}${NO_COLOR}"
    fi

    # Check for staged but not committed changes
    local staged_changes=$(git diff --cached --name-only)
    if [ -n "$staged_changes" ]; then
        print_header
        echo -e "  ↳ has staged changes that are not committed"
        echo -e "${FILE_COLOR}${staged_changes}${NO_COLOR}"
    fi

    # Check for committed but not pushed changes
    local branch=$(git rev-parse --abbrev-ref HEAD)
    if git rev-parse --abbrev-ref --symbolic-full-name @{u} >/dev/null 2>&1; then
        # Upstream exists → check for unpushed commits
        if [ -n "$(git log origin/$branch..HEAD)" ]; then
            print_header
            echo -e "  ↳ Has commits not pushed to origin/$branch"
            echo -e "${FILE_COLOR}$(git log origin/$branch..HEAD --oneline)${NO_COLOR}"
        fi
    else
        # No upstream branch set
        print_header
        echo -e "  ↳ ${PATH_COLOR}No upstream branch set for '$branch'${NO_COLOR}"
    fi

    popd > /dev/null
}

# Function to find all git repositories in the given directory and check their status
find_and_check_git_repos() {
    local root_dir=$1
    for gitdir in $(find "$root_dir" -name ".git" -type d); do
        local repodir=$(dirname "$gitdir")
        check_git_status "$repodir"
    done
}

# Main script execution
find_and_check_git_repos "$TARGET_DIR"
find_and_check_git_repos "$TARGET_DIR2"
