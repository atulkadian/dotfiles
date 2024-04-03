#!/bin/bash

# Install homebrew
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"


# Install homebrew packages
brew bundle install --file=macOS/Brewfile

# Dotfiles directory
DOTFILES_DIR="$HOME/dotfiles"

# Array of dotfiles to symlink
declare -a dotfiles=(
    ".gitconfig"
    ".zshrc"
)

# Create symbolic links
for file in "${dotfiles[@]}"; do
    # Check if the file already exists in the home directory
    if [ -f "$HOME/$file" ]; then
        echo "Backing up existing $file"
        mv "$HOME/$file" "$HOME/$file.bak"
    fi
    # Create symlink
    ln -s "$DOTFILES_DIR/$file" "$HOME/$file"
    echo "Created symlink for $file"
done
