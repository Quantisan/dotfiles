#!/usr/bin/env bash

cd "$(dirname "${BASH_SOURCE}")"

git pull origin main

function doIt() {
        rsync --exclude ".git/" \
                --exclude "templates/" \
                --exclude "launch-agents/" \
                --exclude ".DS_Store" \
                --exclude ".osx" \
                --exclude "bootstrap.sh" \
                --exclude "brew.sh" \
                --exclude "launch-agents.sh" \
                --exclude "README.md" \
                --exclude "CLAUDE.md" \
                --exclude "AGENTS.md" \
                --exclude ".codex/config.toml" \
                --exclude ".cache/" \
                --exclude "LICENSE-MIT.txt" \
                --exclude ".aider.chat.history.md" \
                -avh --no-perms . ~

        ## Link 'llm' templates
        ln -shf "$(pwd)/templates/" ~/Library/Application\ Support/io.datasette.llm/templates

        source ~/.bash_profile
}

if [ "$1" == "--force" -o "$1" == "-f" ]; then
        doIt
else
        read -p "This may overwrite existing files in your home directory. Are you sure? (y/n) " -n 1
        echo ""
        if [[ $REPLY =~ ^[Yy]$ ]]; then
                doIt
        fi
fi
unset doIt
