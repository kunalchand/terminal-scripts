#!/bin/zsh
set -euo pipefail

# ========= CONFIG =========
RESUME_PDF="Kunal_Chand_general.pdf"
RESUME_ZIP="Kunal_Chand_general.zip"
TARGET_NAME="Kunal_Chand_resume.pdf"

DOWNLOADS_DIR="$HOME/Documents/overleaf_files"
OVERLEAF_GENERAL_DIR="/Users/kunalchand/Desktop/projects/others/resume-tracker/overleaf/general"

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
NC="\033[0m"

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

# Increment version: v5.8 -> v5.9, v5.9 -> v6.0
next_version() {
    local ver="${1#v}"
    local major="${ver%.*}"
    local minor="${ver#*.}"
    if [ "$minor" -ge 9 ]; then
        echo "v$((major + 1)).0"
    else
        echo "v${major}.$((minor + 1))"
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
            dryrun_log "cd $repo_path && git add . && git commit -m \"$commit_msg\" && git push"
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
    local version_dir=$1
    local zip_src="$DOWNLOADS_DIR/$RESUME_ZIP"
    check_exists "$zip_src"

    local latex_dir="$version_dir/LaTeX"
    local latex_zip_path="$latex_dir/$RESUME_ZIP"
    local extract_dir="$latex_dir/${RESUME_ZIP%.zip}"

    if [ "$DRY_RUN" = true ]; then
        dryrun_log "mkdir -p \"$latex_dir\""
        dryrun_log "cp \"$zip_src\" \"$latex_zip_path\""
        dryrun_log "unzip -o \"$latex_zip_path\" -d \"$extract_dir\""
    else
        mkdir -p "$latex_dir"
        cp "$zip_src" "$latex_zip_path"
        unzip -o "$latex_zip_path" -d "$extract_dir"
    fi

    echo ""
}

handle_pdf_copy() {
    local version_dir=$1
    local pdf_src="$DOWNLOADS_DIR/$RESUME_PDF"
    check_exists "$pdf_src"

    # Copy PDF into the version folder
    if [ "$DRY_RUN" = true ]; then
        dryrun_log "cp -f \"$pdf_src\" \"$version_dir/$RESUME_PDF\""
    else
        cp -f "$pdf_src" "$version_dir/$RESUME_PDF"
    fi

    # Copy PDF to portfolio site and Desktop
    for DEST in "$PORTFOLIO_DIR" "$DESKTOP_DIR"; do
        check_exists "$DEST"
        local target_path="$DEST/$TARGET_NAME"
        if [ "$DRY_RUN" = true ]; then
            dryrun_log "cp -f \"$pdf_src\" \"$target_path\""
        else
            cp -f "$pdf_src" "$target_path"
        fi
        COPIED_FILES+=("$target_path")
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

# ========= MAIN =========

if [[ "${1:-}" == "--dry-run" ]]; then
    DRY_RUN=true
    log "Running in DRY RUN mode"
    echo ""
fi

# Step 1: Verify source files exist in Documents
log "Checking for source files in $DOWNLOADS_DIR..."
check_exists "$DOWNLOADS_DIR/$RESUME_PDF"
check_exists "$DOWNLOADS_DIR/$RESUME_ZIP"
log "Found: $RESUME_PDF"
log "Found: $RESUME_ZIP"
echo ""

# Step 2: Detect latest version folder
log "Scanning versions in $OVERLEAF_GENERAL_DIR..."
check_exists "$OVERLEAF_GENERAL_DIR"

LATEST_VERSION=$(ls "$OVERLEAF_GENERAL_DIR" | grep -E '^v[0-9]+\.[0-9]+$' | sort -V | tail -1)
if [ -z "$LATEST_VERSION" ]; then
    error_exit "No version folders found in $OVERLEAF_GENERAL_DIR"
fi

NEXT_VERSION=$(next_version "$LATEST_VERSION")
log "Latest version detected: ${CYAN}${LATEST_VERSION}${NC}"
log "Next version would be:   ${CYAN}${NEXT_VERSION}${NC}"
echo ""

# Step 3: Ask user what to do
echo -e "${YELLOW}What would you like to do?${NC}"
echo "  [1] Update existing version (${LATEST_VERSION}) — replace its contents"
echo "  [2] Create new version      (${NEXT_VERSION}) — new folder"
echo ""
printf "Enter choice [1/2]: "
read -r CHOICE
echo ""

if [[ "$CHOICE" == "1" ]]; then
    VERSION="$LATEST_VERSION"
    VERSION_DIR="$OVERLEAF_GENERAL_DIR/$VERSION"
    log "Updating existing version: ${CYAN}${VERSION}${NC}"
    if [ "$DRY_RUN" = true ]; then
        dryrun_log "rm -f \"$VERSION_DIR/$RESUME_PDF\""
        dryrun_log "rm -rf \"$VERSION_DIR/LaTeX\""
    else
        rm -f "$VERSION_DIR/$RESUME_PDF"
        rm -rf "$VERSION_DIR/LaTeX"
    fi
elif [[ "$CHOICE" == "2" ]]; then
    VERSION="$NEXT_VERSION"
    VERSION_DIR="$OVERLEAF_GENERAL_DIR/$VERSION"
    log "Creating new version: ${CYAN}${VERSION}${NC}"
    if [ "$DRY_RUN" = true ]; then
        dryrun_log "mkdir -p \"$VERSION_DIR\""
    else
        mkdir -p "$VERSION_DIR"
    fi
else
    error_exit "Invalid choice '$CHOICE'. Please enter 1 or 2."
fi

echo ""
log "Target directory: $VERSION_DIR"
echo ""

# Step 4: Copy files, then commit and push
handle_latex_zip "$VERSION_DIR"
handle_pdf_copy "$VERSION_DIR"
commit_and_push_if_needed "$RESUME_REPO" "overleaf general $VERSION added"
commit_and_push_if_needed "$PORTFOLIO_REPO" "resume $VERSION added"
print_summary

log "Resume update process completed (DRY_RUN=$DRY_RUN)"
