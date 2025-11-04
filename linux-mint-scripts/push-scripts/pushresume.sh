#!/bin/bash
set -euo pipefail

# ========= CONFIG =========
RESUME_PDF="Kunal_Chand_general.pdf"
RESUME_ZIP="Kunal_Chand_general.zip"
TARGET_NAME="Kunal_Chand_resume.pdf"

PORTFOLIO_DIR="/home/kunalchand/Desktop/Projects/Others/kunalchand.github.io/portfolio/assets"
DESKTOP_DIR="/home/kunalchand/Desktop"

RESUME_REPO="/home/kunalchand/Desktop/Projects/Others/resume-tracker"
PORTFOLIO_REPO="/home/kunalchand/Desktop/Projects/Others/kunalchand.github.io"

DRY_RUN=false
UPDATED_REPOS=()
SKIPPED_REPOS=()
COPIED_FILES=()

# ========= COLORS =========
GREEN="\033[0;32m"
RED="\033[0;31m"
YELLOW="\033[1;33m"
CYAN="\033[0;36m"
NC="\033[0m" # No Color

# ========= FUNCTIONS =========
log() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

error_exit() {
    echo -e "${RED}[ERROR]${NC} $1"
    exit 1
}

dryrun_log() {
    echo -e "${YELLOW}[DRY-RUN]${NC} $*"
}

check_exists() {
    if [ ! -e "$1" ]; then
        error_exit "File or directory not found: $1"
    fi
}

run_cmd() {
    if [ "$DRY_RUN" = true ]; then
        dryrun_log "$*"
    else
        eval "$@"
    fi
}

commit_and_push_if_needed() {
    local repo_path=$1
    local commit_msg=$2
    local repo_name=$(basename "$repo_path")

    log "Checking repo: $repo_path"
    check_exists "$repo_path"
    cd "$repo_path"

    if [ "$DRY_RUN" = true ]; then
        if [[ -n "$(git status --porcelain)" ]]; then
            log "Would commit in ${repo_name} with message: ${CYAN}$commit_msg${NC} by executing:"
            dryrun_log "cd $repo_path"
            dryrun_log "git add ."
            dryrun_log "git commit -m \"$commit_msg\""
            dryrun_log "git push"
            UPDATED_REPOS+=("$repo_name")
        else
            log "No changes detected in ${repo_name} (dry-run), would skip."
            SKIPPED_REPOS+=("$repo_name")
        fi
    else
        if [[ -n "$(git status --porcelain)" ]]; then
            log "Committing in ${repo_name} with message: ${CYAN}$commit_msg${NC}"
            git add .
            git commit -m "$commit_msg"
            git push || error_exit "Git push failed in $repo_path"
            UPDATED_REPOS+=("$repo_name")
        else
            log "No changes detected in ${repo_name}, skipping commit."
            SKIPPED_REPOS+=("$repo_name")
        fi
    fi

    echo ""  # Blank line for readability
}

# ========= LaTeX HANDLING FUNCTION =========
handle_latex_zip() {
    check_exists "$RESUME_ZIP"

    LATEX_DIR="LaTeX"
    LATEX_ZIP_PATH="$LATEX_DIR/$RESUME_ZIP"
    EXTRACT_DIR="$LATEX_DIR/${RESUME_ZIP%.zip}"

    if [ "$DRY_RUN" = true ]; then
        log "Would create folder $LATEX_DIR if it doesn't exist by executing:"
        dryrun_log "mkdir -p \"$LATEX_DIR\""
        log "Would move $RESUME_ZIP into $LATEX_DIR/ by executing:"
        dryrun_log "mv \"$RESUME_ZIP\" \"$LATEX_DIR/\""
        log "Would extract $LATEX_ZIP_PATH into $EXTRACT_DIR by executing:"
        dryrun_log "unzip -o \"$LATEX_ZIP_PATH\" -d \"$EXTRACT_DIR\""
    else
        log "Creating folder $LATEX_DIR if it doesn't exist"
        mkdir -p "$LATEX_DIR"
        log "Moving $RESUME_ZIP into $LATEX_DIR/"
        mv "$RESUME_ZIP" "$LATEX_DIR/"
        log "Extracting $LATEX_ZIP_PATH into $EXTRACT_DIR"
        unzip -o "$LATEX_ZIP_PATH" -d "$EXTRACT_DIR"
    fi

    echo ""  # Blank line
}

# ========= PDF COPY HANDLING FUNCTION =========
handle_pdf_copy() {
    check_exists "$RESUME_PDF"

    for DEST in "$PORTFOLIO_DIR" "$DESKTOP_DIR"; do
        check_exists "$DEST"
        TARGET_PATH="$DEST/$TARGET_NAME"

        if [ "$DRY_RUN" = true ]; then
            log "Would copy $RESUME_PDF to $TARGET_PATH by executing:"
            dryrun_log "cp -f \"$RESUME_PDF\" \"$TARGET_PATH\""
        else
            log "Copying $RESUME_PDF to $TARGET_PATH"
            cp -f "$RESUME_PDF" "$TARGET_PATH"
        fi

        COPIED_FILES+=("$TARGET_PATH")
    done

    echo ""  # Blank line
}

# ========= SUMMARY FUNCTION =========
print_summary() {
    echo -e "\n${CYAN}========= SUMMARY =========${NC}"

    # Copied PDFs
    if [ ${#COPIED_FILES[@]} -gt 0 ]; then
        if [ "$DRY_RUN" = true ]; then
            echo -e "📄 PDF files that WOULD be copied:"
        else
            echo -e "📄 Copied PDF files:"
        fi
        for file in "${COPIED_FILES[@]}"; do
            echo -e "   - $file"
        done
    else
        echo -e "📄 Copied PDF files: None"
    fi
    echo ""  # Blank line

    # Updated repos
    if [ ${#UPDATED_REPOS[@]} -gt 0 ]; then
        if [ "$DRY_RUN" = true ]; then
            echo -e "✅ Repos that WOULD be updated:"
        else
            echo -e "✅ Repos updated:"
        fi
        for repo in "${UPDATED_REPOS[@]}"; do
            echo -e "   - $repo"
        done
    else
        echo -e "✅ Repos updated: None"
    fi
    echo ""  # Blank line

    # Skipped repos
    if [ ${#SKIPPED_REPOS[@]} -gt 0 ]; then
        if [ "$DRY_RUN" = true ]; then
            echo -e "⏩ Repos that WOULD be skipped:"
        else
            echo -e "⏩ Repos skipped:"
        fi
        for repo in "${SKIPPED_REPOS[@]}"; do
            echo -e "   - $repo"
        done
    else
        echo -e "⏩ Repos skipped: None"
    fi

    echo -e "${CYAN}===========================${NC}\n"
}

# ========= MAIN =========
# Parse args
if [[ "${1:-}" == "--dry-run" ]]; then
    DRY_RUN=true
    log "Running in DRY RUN mode (no changes will be made)"
    echo ""  # Blank line
fi

CURRENT_DIR=$(pwd)
VERSION=$(basename "$CURRENT_DIR")

log "Current directory: $CURRENT_DIR"
log "Detected version: $VERSION"
echo ""  # Blank line

# 1. Handle LaTeX zip
handle_latex_zip

# 2. Handle PDF copy
handle_pdf_copy

# 3. Commit and push in resume-tracker repo
commit_and_push_if_needed "$RESUME_REPO" "overleaf general $VERSION added"

# 4. Commit and push in portfolio repo
commit_and_push_if_needed "$PORTFOLIO_REPO" "resume $VERSION added"

# 5. Print summary
print_summary

log "Resume update process completed (DRY_RUN=$DRY_RUN)"
