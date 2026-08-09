#!/usr/bin/env bash
#
# Set up a Mac from this repo. Safe to re-run: symlinks that already point
# here are left alone, and anything else is backed up before being replaced.
#
#   ./install.sh                 # everything
#   ./install.sh --skills        # just the agent skills
#   ./install.sh --dry-run       # print what would happen, change nothing
#
set -euo pipefail

REPO="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
STAMP="$(date +%Y%m%d%H%M%S)"
DRY_RUN=0

do_dotfiles=0
do_brew=0
do_skills=0

# Where agent skills get linked. Both tools read SKILL.md the same way, so a
# single skills/ directory serves both.
SKILL_TARGETS=(
    "$HOME/.claude/skills"
    "$HOME/.cursor/skills"
)

# --- helpers ---------------------------------------------------------------

info() { printf '\033[0;34m==>\033[0m %s\n' "$*"; }
warn() { printf '\033[0;33m warn\033[0m %s\n' "$*"; }
skip() { printf '\033[0;90m skip\033[0m %s\n' "$*"; }
ok()   { printf '\033[0;32m link\033[0m %s\n' "$*"; }

run() {
    if [ "$DRY_RUN" -eq 1 ]; then
        printf '\033[0;90m  would run: %s\033[0m\n' "$*"
    else
        "$@"
    fi
}

# Replace $HOME with ~ so output stays readable.
tilde() {
    local t='~'
    printf '%s' "${1/#$HOME/$t}"
}

# Move whatever is currently at $1 out of the way.
back_up() {
    local target="$1"
    if [ ! -e "$target" ] && [ ! -L "$target" ]; then
        return 0
    fi
    warn "backing up $(tilde "$target") -> $(tilde "$target").bak.$STAMP"
    run mv "$target" "$target.bak.$STAMP"
}

# link <source> <target>
link() {
    local src="$1" target="$2"
    if [ -L "$target" ] && [ "$(readlink "$target")" = "$src" ]; then
        skip "$(tilde "$target") (already linked)"
        return 0
    fi
    back_up "$target"
    run mkdir -p "$(dirname "$target")"
    run ln -s "$src" "$target"
    ok "$(tilde "$target") -> $(tilde "$src")"
}

# --- steps -----------------------------------------------------------------

# Everything under home/ is mirrored into $HOME at the same relative path, so
# nested files (like the oh-my-zsh theme) land where they belong. Files are
# linked one by one rather than linking whole directories, which would shadow
# directories that other tools own — ~/.oh-my-zsh being the obvious one.
install_dotfiles() {
    info "Linking dotfiles"
    local rel
    while IFS= read -r rel; do
        link "$REPO/home/$rel" "$HOME/$rel"
    done < <(cd "$REPO/home" && find . -type f ! -name '.DS_Store' | sed 's|^\./||')
}

install_brew() {
    info "Homebrew"
    if ! command -v brew >/dev/null 2>&1; then
        warn "Homebrew not found, installing"
        run /bin/bash -c \
            "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
        # A fresh install is not on PATH yet in this shell.
        if [ -x /opt/homebrew/bin/brew ]; then
            eval "$(/opt/homebrew/bin/brew shellenv)"
        elif [ -x /usr/local/bin/brew ]; then
            eval "$(/usr/local/bin/brew shellenv)"
        fi
    else
        skip "Homebrew already installed"
    fi
    run brew bundle install --file="$REPO/macOS/Brewfile"
}

# The whole skills/ directory is linked as one unit, so `git pull` in this repo
# immediately updates every agent without re-running this script.
install_skills() {
    info "Linking agent skills"
    local target
    for target in "${SKILL_TARGETS[@]}"; do
        link "$REPO/skills" "$target"
    done
}

# --- args ------------------------------------------------------------------

while [ $# -gt 0 ]; do
    case "$1" in
        --dotfiles) do_dotfiles=1 ;;
        --brew)     do_brew=1 ;;
        --skills)   do_skills=1 ;;
        --all)      do_dotfiles=1; do_brew=1; do_skills=1 ;;
        --dry-run)  DRY_RUN=1 ;;
        -h|--help)
            sed -n '2,9p' "${BASH_SOURCE[0]}" | sed 's|^#\{1\} \{0,1\}||'
            exit 0
            ;;
        *)
            echo "unknown option: $1" >&2
            exit 1
            ;;
    esac
    shift
done

# No step flags means do everything.
if [ $((do_dotfiles + do_brew + do_skills)) -eq 0 ]; then
    do_dotfiles=1
    do_brew=1
    do_skills=1
fi

if [ "$DRY_RUN" -eq 1 ]; then
    info "Dry run: nothing will be changed"
fi

if [ "$do_dotfiles" -eq 1 ]; then install_dotfiles; fi
if [ "$do_brew" -eq 1 ]; then install_brew; fi
if [ "$do_skills" -eq 1 ]; then install_skills; fi

info "Done"
