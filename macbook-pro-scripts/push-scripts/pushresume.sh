#!/bin/zsh
set -euo pipefail

# ========= CONFIG =========
RESUME_PDF="Kunal_Chand_general.pdf"
RESUME_ZIP="Kunal_Chand_general.zip"
TARGET_NAME="Kunal_Chand_resume.pdf"

# macOS paths
PORTFOLIO_DIR="/Users/kunalchand/Desktop/projects/others/kunalchand.github.io/portfolio/assets"
DESKTOP_DIR="/Users/kunalchand/Desktop"

RESUME_REPO="/Users/kunalchand/Desktop/projects/others/resume-tracker"
PORTFOLIO_REPO="/Users/kunalchand/Desktop/projects/others/kunalchand.github.io"

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
            log "Would commit in ${repo_name} with message: ${CYAN}$commit_msg${NC}"
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

    echo ""
}

handle_latex_zip() {
    check_exists "$RESUME_ZIP"

    LATEX_DIR="LaTeX"
    LATEX_ZIP_PATH="$LATEX_DIR/$RESUME_ZIP"
    EXTRACT_DIR="$LATEX_DIR/${RESUME_ZIP%.zip}"

    if [ "$DRY_RUN" = true ]; then
        dryrun_log "mkdir -p \"$LATEX_DIR\""
        dryrun_log "mv \"$RESUME_ZIP\" \"$LATEX_DIR/\""
        dryrun_log "unzip -o \"$LATEX_ZIP_PATH\" -d \"$EXTRACT_DIR\""
    else
        mkdir -p "$LATEX_DIR"
        mv "$RESUME_ZIP" "$LATEX_DIR/"
        unzip -o "$LATEX_ZIP_PATH" -d "$EXTRACT_DIR"
    fi

    echo ""
}

handle_pdf_copy() {
    check_exists "$RESUME_PDF"

    for DEST in "$PORTFOLIO_DIR" "$DESKTOP_DIR"; do
        check_exists "$DEST"
        TARGET_PATH="$DEST/$TARGET_NAME"

        if [ "$DRY_RUN" = true ]; then
            dryrun_log "cp -f \"$RESUME_PDF\" \"$TARGET_PATH\""
        else
            cp -f "$RESUME_PDF" "$TARGET_PATH"
        fi

        COPIED_FILES+=("$TARGET_PATH")
    done

    echo ""
}

print_summary() {
    echo -e "\n${CYAN}========= SUMMARY =========${NC}"

    if [ ${#COPIED_FILES[@]} -gt 0 ]; then
        echo "📄 Copied PDFs:"
        for file in "${COPIED_FILES[@]}"; do echo "   - $file"; done
    else
        echo "📄 None copied"
    fi
    echo ""

    if [ ${#UPDATED_REPOS[@]} -gt 0 ]; then
        echo "✅ Updated repos:"
        for repo in "${UPDATED_REPOS[@]}"; do echo "   - $repo"; done
    else
        echo "✅ None updated"
    fi
    echo ""

    if [ ${#SKIPPED_REPOS[@]} -gt 0 ]; then
        echo "⏩ Skipped repos:"
        for repo in "${SKIPPED_REPOS[@]}"; do echo "   - $repo"; done
    else
        echo "⏩ None skipped"
    fi

    echo -e "${CYAN}===========================${NC}\n"
}

if [[ "${1:-}" == "--dry-run" ]]; then
    DRY_RUN=true
    log "Running in DRY RUN mode"
    echo ""
fi

CURRENT_DIR=$(pwd)
VERSION=$(basename "$CURRENT_DIR")

log "Current directory: $CURRENT_DIR"
log "Detected version: $VERSION"
echo ""

handle_latex_zip
handle_pdf_copy
commit_and_push_if_needed "$RESUME_REPO" "overleaf general $VERSION added"
commit_and_push_if_needed "$PORTFOLIO_REPO" "resume $VERSION added"
print_summary

log "Resume update process completed (DRY_RUN=$DRY_RUN)"
