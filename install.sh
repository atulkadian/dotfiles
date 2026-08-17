#!/usr/bin/env bash
#
# Set up a Mac from this repo. Safe to re-run: symlinks that already point
# here are left alone, and anything else is backed up before being replaced.
#
#   ./install.sh                 # everything
#   ./install.sh --skills        # just the agent skills
#   ./install.sh --dry-run       # print what would happen, change nothing
#   ./install.sh --export-terminal   # pull live Terminal.app settings into the repo
#
set -euo pipefail

REPO="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
STAMP="$(date +%Y%m%d%H%M%S)"
DRY_RUN=0

do_dotfiles=0
do_brew=0
do_skills=0
do_terminal=0
do_export=0

# Terminal.app profile to make the default. Must match the `name` key inside
# one of the .terminal files in macOS/terminal/.
TERMINAL_PROFILE="Clear Dark"

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
save() { printf '\033[0;32m save\033[0m %s\n' "$*"; }

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

# link <source> <target> [fresh]
#
# `fresh` means the parent directory was just created by this run and is known
# to be empty, so there is nothing to inspect or back up. Without it, a dry run
# would report backups for files that only appear to exist because the earlier
# steps it was reporting on did not actually happen.
link() {
    local src="$1" target="$2" fresh="${3:-0}"
    if [ "$fresh" = "1" ]; then
        run ln -s "$src" "$target"
        ok "$(tilde "$target") -> $(tilde "$src")"
        return 0
    fi
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

# Terminal.app keeps its profiles inside a preferences domain rather than a
# file we can symlink, so these are imported rather than linked. Re-export
# after changing settings in the UI:
#
#   ./install.sh --export-terminal
#
install_terminal() {
    info "Terminal.app profiles"
    local file profile
    shopt -s nullglob
    for file in "$REPO"/macOS/terminal/*.terminal; do
        profile="$(plutil -extract name raw -o - "$file")"
        if profile_installed "$profile"; then
            if profile_matches "$profile" "$file"; then
                skip "profile \"$profile\" already matches"
                continue
            fi
            # The profile exists under this name but its settings have moved
            # on in the repo. Overwrite it in place; `open` would not, since
            # Terminal treats an existing name as nothing to import.
            if pgrep -xq Terminal; then
                warn "profile \"$profile\" differs from the repo, but Terminal is running."
                warn "Quit Terminal and run this again to update it."
                continue
            fi
            run defaults write com.apple.Terminal "Window Settings" \
                -dict-add "$profile" "$(cat "$file")"
            ok "updated profile \"$profile\""
            continue
        fi
        # Terminal.app is asked to import the file itself, instead of writing
        # the profile with `defaults`. A running Terminal holds its
        # preferences in memory and rewrites the whole domain when it quits,
        # which would silently discard anything written underneath it.
        # Importing through the app puts the profile in that in-memory copy.
        run open -a Terminal "$file"
        ok "imported profile \"$profile\""
    done
    shopt -u nullglob

    if profile_installed "$TERMINAL_PROFILE"; then
        run defaults write com.apple.Terminal "Default Window Settings" -string "$TERMINAL_PROFILE"
        run defaults write com.apple.Terminal "Startup Window Settings" -string "$TERMINAL_PROFILE"
        ok "default profile set to \"$TERMINAL_PROFILE\""
        if pgrep -xq Terminal; then
            warn "Terminal is running: quit and reopen it for this to stick."
            warn "If it does not, set \"$TERMINAL_PROFILE\" as Default in"
            warn "Terminal > Settings > Profiles (the profile is imported either way)."
        fi
    else
        warn "profile \"$TERMINAL_PROFILE\" not found; leaving the default alone"
    fi
}

profile_installed() {
    defaults export com.apple.Terminal - \
        | plutil -extract "Window Settings.$1.name" raw -o - - >/dev/null 2>&1
}

# True when the profile stored in Terminal.app is identical to the file.
# Checking the name alone would leave an out-of-date profile in place forever.
profile_matches() {
    local tmp status
    tmp="$(mktemp)"
    if defaults export com.apple.Terminal - \
        | plutil -extract "Window Settings.$1" xml1 -o "$tmp" - 2>/dev/null \
        && diff -q "$tmp" "$2" >/dev/null 2>&1; then
        status=0
    else
        status=1
    fi
    rm -f "$tmp"
    return "$status"
}

# Copy the live Terminal.app profile back into the repo, so settings changed
# in the UI can be committed.
export_terminal() {
    info "Exporting Terminal.app profile \"$TERMINAL_PROFILE\""
    local out
    out="$REPO/macOS/terminal/$(echo "$TERMINAL_PROFILE" | tr '[:upper:] ' '[:lower:]-').terminal"
    if ! profile_installed "$TERMINAL_PROFILE"; then
        warn "profile \"$TERMINAL_PROFILE\" is not defined in Terminal.app"
        return 1
    fi
    if [ "$DRY_RUN" -eq 1 ]; then
        printf '\033[0;90m  would write: %s\033[0m\n' "$(tilde "$out")"
        return 0
    fi
    defaults export com.apple.Terminal - \
        | plutil -extract "Window Settings.$TERMINAL_PROFILE" xml1 -o "$out" -
    save "$(tilde "$out")"
}

# Each skill is linked individually, rather than linking skills/ as one
# directory. That keeps the agent's skills directory a real directory, which
# matters for two reasons:
#
#   1. Skills already on the machine keep working, instead of being hidden
#      behind a symlink to this repo.
#   2. Skills an agent creates later (Cursor's create-skill writes to
#      ~/.cursor/skills) land on the local disk, not inside this repo. This
#      repo is public, so work-specific skills must not be able to drift into
#      it by accident.
#
# The cost is that a `git pull` adding a new skill needs this step re-run to
# link it.
install_skills() {
    info "Linking agent skills"
    local target dir existing fresh
    for target in "${SKILL_TARGETS[@]}"; do
        fresh=0
        # An earlier version of this script linked the directory itself.
        # Replace that with a real directory; nothing is lost, since the link
        # only ever pointed back here.
        if [ -L "$target" ] && [ "$(readlink "$target")" = "$REPO/skills" ]; then
            warn "replacing directory symlink at $(tilde "$target")"
            run rm "$target"
            fresh=1
        fi
        [ -d "$target" ] || fresh=1
        run mkdir -p "$target"

        shopt -s nullglob
        for dir in "$REPO"/skills/*/; do
            link "${dir%/}" "$target/$(basename "$dir")" "$fresh"
        done

        # Drop links to skills that have since been removed from the repo.
        for existing in "$target"/*; do
            if [ -L "$existing" ] && [ ! -e "$existing" ]; then
                case "$(readlink "$existing")" in
                    "$REPO"/skills/*)
                        run rm "$existing"
                        warn "removed stale link $(tilde "$existing")"
                        ;;
                esac
            fi
        done
        shopt -u nullglob
    done
}

# --- args ------------------------------------------------------------------

while [ $# -gt 0 ]; do
    case "$1" in
        --dotfiles) do_dotfiles=1 ;;
        --brew)     do_brew=1 ;;
        --skills)   do_skills=1 ;;
        --terminal) do_terminal=1 ;;
        --all)      do_dotfiles=1; do_brew=1; do_skills=1; do_terminal=1 ;;
        --dry-run)  DRY_RUN=1 ;;
        --export-terminal) do_export=1 ;;
        -h|--help)
            sed -n '2,10p' "${BASH_SOURCE[0]}" | sed 's|^#\{1\} \{0,1\}||'
            exit 0
            ;;
        *)
            echo "unknown option: $1" >&2
            exit 1
            ;;
    esac
    shift
done

if [ "$DRY_RUN" -eq 1 ]; then
    info "Dry run: nothing will be changed"
fi

# Exporting is the reverse of installing, so it runs on its own.
if [ "$do_export" -eq 1 ]; then
    export_terminal
    exit 0
fi

# No step flags means do everything.
if [ $((do_dotfiles + do_brew + do_skills + do_terminal)) -eq 0 ]; then
    do_dotfiles=1
    do_brew=1
    do_skills=1
    do_terminal=1
fi

if [ "$do_dotfiles" -eq 1 ]; then install_dotfiles; fi
if [ "$do_brew" -eq 1 ]; then install_brew; fi
if [ "$do_skills" -eq 1 ]; then install_skills; fi
if [ "$do_terminal" -eq 1 ]; then install_terminal; fi

info "Done"
