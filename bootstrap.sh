#!/usr/bin/env bash

cd "$(dirname "${BASH_SOURCE}")"

## Absolute path of this repo; every symlink created below points into it
repo_dir="$(pwd)"

## link SRC DEST: make DEST a symlink to SRC, replacing any existing file or link.
## A real directory at DEST is replaced only when it is an identical copy of SRC
## (left by an older bootstrap); any other real directory is skipped with a warning.
function link() {
        local src="$1" dest="$2"
        mkdir -p "$(dirname "$dest")"
        ## DEST already resolves to SRC (e.g. through a symlinked parent); replacing it would delete SRC
        if [ "$src" -ef "$dest" ]; then
                return
        fi
        if [ -d "$dest" ] && [ ! -L "$dest" ]; then
                if [ -d "$src" ] && command diff -rq "$src" "$dest" > /dev/null 2>&1; then
                        rm -rf "$dest"
                else
                        echo "warning: $dest is a real directory that differs from $src; skipping" >&2
                        return
                fi
        fi
        ln -shf "$src" "$dest"
}

## link_entries SRC_DIR DEST_DIR: link each entry of SRC_DIR into DEST_DIR, then remove
## dangling links in DEST_DIR that point into this repo. Other tools also write into these
## directories, so DEST_DIR itself is never replaced and unrelated entries are left alone.
function link_entries() {
        local src_dir="$1" dest_dir="$2" entry
        mkdir -p "$dest_dir"
        for entry in "$src_dir"/* "$src_dir"/.[!.]*; do
                if [ -e "$entry" ] && [ "$(basename "$entry")" != ".DS_Store" ]; then
                        link "$entry" "$dest_dir/$(basename "$entry")"
                fi
        done
        for entry in "$dest_dir"/* "$dest_dir"/.[!.]*; do
                if [ -L "$entry" ] && [ ! -e "$entry" ]; then
                        case "$(readlink "$entry")" in
                                "$repo_dir"/*) rm "$entry" ;;
                        esac
                fi
        done
}

## Deploys whatever is checked out; pull yourself when you want the latest

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
                --exclude "agents/" \
                --exclude ".codex/" \
                --exclude ".pi/" \
                --exclude ".cache/" \
                --exclude ".claude/" \
                --exclude ".gemini/" \
                --exclude ".github/" \
                --exclude "LICENSE-MIT.txt" \
                -avh --no-perms . ~

        ## Set up Git identity and signing preferences
        bash "$repo_dir/git-setup.sh"

        ## Link 'llm' templates
        ln -shf "$repo_dir/templates/" ~/Library/Application\ Support/io.datasette.llm/templates

        ## Shared by all agents: skills (Codex and agy read ~/.agents/skills; Claude Code
        ## does not, so it gets its own links), Clojure conventions, and global rules
        link_entries "$repo_dir/agents/skills" ~/.agents/skills
        link_entries "$repo_dir/agents/skills" ~/.claude/skills
        link "$repo_dir/agents/clojure.md" ~/.agents/clojure.md
        link "$repo_dir/agents/AGENTS.md" ~/.claude/CLAUDE.md
        link "$repo_dir/agents/AGENTS.md" ~/.codex/AGENTS.md
        link "$repo_dir/agents/AGENTS.md" ~/.gemini/config/AGENTS.md
        link "$repo_dir/agents/AGENTS.md" ~/.pi/agent/AGENTS.md

        ## Set up Claude Code config
        link "$repo_dir/.claude/settings.json" ~/.claude/settings.json
        link "$repo_dir/.claude/statusline.clj" ~/.claude/statusline.clj
        link_entries "$repo_dir/.claude/commands" ~/.claude/commands
        link_entries "$repo_dir/.claude/skills" ~/.claude/skills
        link_entries "$repo_dir/.claude/agents" ~/.claude/agents
        link_entries "$repo_dir/.claude/workflows" ~/.claude/workflows
        ## Record the canonical source path so skills can reference this repo
        ## without hardcoding its checkout location
        pwd > ~/.claude/workflows/.source

        ## Set up Codex config
        link "$repo_dir/.codex/personal.config.toml" ~/.codex/personal.config.toml
        link_entries "$repo_dir/.codex/skills" ~/.codex/skills

        ## Set up pi config
        link "$repo_dir/.pi/settings.json" ~/.pi/agent/settings.json
        link "$repo_dir/.pi/extensions" ~/.pi/agent/extensions

        ## Set up Antigravity (agy) config
        link "$repo_dir/.gemini/antigravity-cli/personal.settings.json" ~/.gemini/antigravity-cli/personal.settings.json
        link "$repo_dir/.gemini/antigravity-cli/statusline.clj" ~/.gemini/antigravity-cli/statusline.clj
        link "$repo_dir/.gemini/config/config.json" ~/.gemini/config/config.json
        link "$repo_dir/.gemini/config/mcp_config.json" ~/.gemini/config/mcp_config.json

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
unset -f doIt link link_entries
unset repo_dir
