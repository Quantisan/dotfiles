#!/usr/bin/env bash
set -euo pipefail

NUB="/Volumes/nub"

if [ ! -d "$NUB" ]; then
        echo "Note: $NUB not mounted; skipping symlink setup."
        exit 0
fi

# Symlink external volume directories
ln -shf "$NUB/Movies" "$HOME/Movies_nub"
ln -shf "$NUB/Downloads" "$HOME/Downloads_nub"
ln -shf "$NUB/Projects" "$HOME/Projects"

# Ensure parent exists and symlink Homebrew cache into Library/Caches
mkdir -p "$HOME/Library/Caches"
ln -shf "$NUB/Library/Caches/Homebrew" "$HOME/Library/Caches/Homebrew"
ln -shf "$NUB/Library/Caches/com.goodsnooze.MacWhisper" "$HOME/Library/Caches/com.goodsnooze.MacWhisper"
ln -shf "$NUB/Library/Caches/com.spotify.client" "$HOME/Library/Caches/com.spotify.client"

mkdir -p "$HOME/Library/Homebrew"
ln -shf "$NUB/Library/Homebrew/downloads/" "$HOME/Library/Homebrew/downloads"
ln -shf "$NUB/Library/Homebrew/Casks/" "$HOME/Library/Homebrew/Casks"

# Application Support
mkdir -p "$HOME/Library/Application\ Support"
ln -shf "$NUB/Library/Application\ Support/MacWhisper/" "$HOME/Library/Application\ Support/MacWhisper"

# XDG-like data/cache locations
mkdir -p "$HOME/.local"
ln -shf "$NUB/.local/share" "$HOME/.local/share"
ln -shf "$NUB/.cache" "$HOME/.cache"

echo "Symlink setup complete."
