# ============================================================================
# ZSHRC CONFIGURATION
# ============================================================================

# ----------------------------------------------------------------------------
# Section: Git Integration & Prompt Customization
# Purpose: Display Git branch with dynamic colors based on repo state
#          - Green: Clean repository
#          - Red *: Unstaged changes
#          - Yellow +: Staged changes
#          - Magenta ?: Untracked files
#          - Cyan ↑: Unpushed commits
# ----------------------------------------------------------------------------

autoload -Uz vcs_info
precmd() { vcs_info }

# Enable checking for changes (staged and unstaged)
zstyle ':vcs_info:*' enable git
zstyle ':vcs_info:*' check-for-changes true

# Format strings with color indicators and %m for misc (unpushed commits + untracked)
zstyle ':vcs_info:git:*' formats '%F{green}(%b%u%c%m)%f'
zstyle ':vcs_info:git:*' actionformats '%F{magenta}(%b|%a%u%c%m)%f'

# Color indicators for unstaged (*) and staged (+) changes
zstyle ':vcs_info:git:*' unstagedstr ' %F{red}*%f'
zstyle ':vcs_info:git:*' stagedstr ' %F{yellow}+%f'

# Register custom hooks for unpushed commits and untracked files
zstyle ':vcs_info:git*+set-message:*' hooks git-untracked git-unpushed

# Hook to detect untracked files
+vi-git-untracked() {
    if [[ $(git rev-parse --is-inside-work-tree 2> /dev/null) == 'true' ]] && \
       git status --porcelain | grep -m 1 '^??' &>/dev/null
    then
        hook_com[misc]+=' %F{magenta}?%f'
    fi
}

# Hook to detect unpushed commits (commits ahead of remote)
+vi-git-unpushed() {
    local ahead
    ahead=$(git rev-list --count @{upstream}..HEAD 2>/dev/null)
    if [[ -n "$ahead" && "$ahead" -gt 0 ]]; then
        hook_com[misc]+=" %F{cyan}↑${ahead}%f"
    fi
}

setopt PROMPT_SUBST

# Prompt: username@host cyan path, git info, $ symbol
PROMPT='%n@MacBookPro %F{cyan}%~%f${vcs_info_msg_0_:+ ${vcs_info_msg_0_}} $ '

# ----------------------------------------------------------------------------
# Section: External Aliases
# Purpose: Load custom aliases from external file
# ----------------------------------------------------------------------------

ALIAS_FILE=~/Desktop/projects/others/terminal-scripts/macbook-pro-scripts/zshrc-aliases.zsh
if [ -f "$ALIAS_FILE" ]; then
    source "$ALIAS_FILE"
fi

# ----------------------------------------------------------------------------
# Section: Python Environment (Pyenv)
# Purpose: Initialize pyenv for Python version management
# ----------------------------------------------------------------------------

export PYENV_ROOT="$HOME/.pyenv"
export PATH="$PYENV_ROOT/bin:$PATH"
eval "$(pyenv init --path)"
eval "$(pyenv init -)"

# ============================================================================
# END OF CONFIGURATION
# ============================================================================