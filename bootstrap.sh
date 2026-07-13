#!/usr/bin/env bash

cd "$(dirname "${BASH_SOURCE}")"

git pull origin master

function doIt() {
        rsync --exclude ".git/" \
                --exclude "templates/" \
                --exclude ".DS_Store" \
                --exclude ".osx" \
                --exclude "bootstrap.sh" \
                --exclude "brew.sh" \
                --exclude "docs/" \
                --exclude "git-setup.sh" \
                --exclude "README.md" \
                --exclude "CLAUDE.md" \
                --exclude "AGENTS.md" \
                --exclude ".codex/config.toml" \
                --exclude ".codex/personal.config.toml" \
                --exclude ".pi/" \
                --exclude ".cache/" \
                --exclude ".claude/" \
                --exclude ".github/" \
                --exclude "LICENSE-MIT.txt" \
                -avh --no-perms . ~

        ## Set up Git identity and signing preferences
        bash "$(pwd)/git-setup.sh"

        ## Link 'llm' templates
        ln -shf "$(pwd)/templates/" ~/Library/Application\ Support/io.datasette.llm/templates

        ## Set up Claude Code config
        mkdir -p ~/.claude
        ln -shf "$(pwd)/.claude/settings.json" ~/.claude/settings.json
        cp .claude/CLAUDE.md ~/.claude/CLAUDE.md
        cp .claude/clojure.md ~/.claude/clojure.md
        rsync -avh --delete \
                --exclude "rk-*.md" \
                .claude/commands/ ~/.claude/commands/
        rsync -avh --delete .claude/skills/ ~/.claude/skills/
        rsync -avh --delete .claude/agents/ ~/.claude/agents/
        rsync -avh --delete .claude/workflows/ ~/.claude/workflows/
        ## Record the canonical source path so skills can reference this repo
        ## without hardcoding its checkout location
        pwd > ~/.claude/workflows/.source

        ## Set up Codex config
        mkdir -p ~/.codex
        ln -shf "$(pwd)/.codex/personal.config.toml" ~/.codex/personal.config.toml

        ## Set up pi config
        mkdir -p ~/.pi/agent
        ln -shf "$(pwd)/.pi/settings.json" ~/.pi/agent/settings.json
        ln -shf "$(pwd)/.claude/CLAUDE.md" ~/.pi/agent/AGENTS.md
        ln -shf "$(pwd)/.pi/extensions" ~/.pi/agent/extensions

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
