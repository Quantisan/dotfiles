# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Repository Overview

This is a personal macOS dotfiles repository, based on Mathias Bynens' dotfiles but customized for a development environment that includes Clojure, Python, AWS, Docker, and various AI/LLM tools.

## Installation and Setup Commands

### Install/Update Dotfiles
```bash
source bootstrap.sh
```
This syncs dotfiles to your home directory and creates a symlink for LLM templates.

For force update without confirmation:
```bash
source bootstrap.sh -f
```

### Install Homebrew Packages
```bash
./brew.sh
```
Installs all development tools, applications, and fonts via Homebrew.

### Apply macOS System Defaults
```bash
./.macos
```
Configures macOS system preferences (Finder, Dock, keyboard, etc.).

### Set up LaunchAgents
```bash
./launch-agents.sh
```
Symlinks LaunchAgent plist files to `~/Library/LaunchAgents/` and loads them. Currently manages:
- `claude-auto-renew` - Pings Claude CLI Monday-Saturday at 4:30 AM to maintain session

For force setup without confirmation:
```bash
./launch-agents.sh -f
```

## Architecture

### Modular Dotfile Loading System

The `.bash_profile` loads dotfiles in this order:
1. `~/.path` - Custom PATH extensions
2. `~/.bash_prompt` - Shell prompt configuration
3. `~/.exports` - Environment variables
4. `~/.aliases` - Shell aliases
5. `~/.functions` - Custom shell functions
6. `~/.extra` - Private/local settings (not tracked in git)
7. `~/.secrets` - Sensitive credentials (not tracked in git)

This modular approach allows customization without forking—use `~/.extra` for personal overrides.

### LLM Templates Integration

The `bootstrap.sh` script creates a symlink:
```
~/Library/Application Support/io.datasette.llm/templates -> $(pwd)/templates/
```

This integrates custom LLM prompt templates (in `templates/`) with the `llm` CLI tool. Notable templates include:
- `pr.yaml` - Generates PR titles and descriptions focused on business impact
- `youtube.yaml` - Uses Gemini 2.5 Flash for YouTube content analysis
- Various others for code review, refactoring, communication, etc.

### LaunchAgents Integration

The `launch-agents.sh` script manages macOS LaunchAgents that run scheduled tasks:
```
launch-agents/ -> symlinked to ~/Library/LaunchAgents/
```

**claude-auto-renew** (`com.quantisan.claude-auto-renew.plist`):
- Runs Monday-Saturday at 4:30 AM
- Executes `echo "ping" | claude -p` to keep Claude CLI session alive
- Logs to `~/.claude-cron.log`
- Prevents session expiration for daily Claude CLI usage

### Claude Code Configuration

The `.claude/` folder is the **source** for `~/.claude/` (global Claude Code config):
- `.claude/CLAUDE.md` → copied to `~/.claude/CLAUDE.md` (global instructions)
- `.claude/commands/` → copied to `~/.claude/commands/` (custom slash commands)
- `.claude/settings.json` → copied to `~/.claude/settings.json`

**Important:** Edits to `.claude/` files require running `source bootstrap.sh` to copy them to `~/.claude/` and take effect globally.

### Custom Function Wrappers

**Aider wrapper** (`.functions:184-188`): Wraps the Aider AI coding assistant with API keys from environment variables:
```bash
aider() {
    command aider --anthropic-api-key "$AIDER_ANTHROPIC_API_KEY" --openai-api-key "$AIDER_OPENAI_API_KEY" "$@"
}
```

**Reader function** (`.functions:173-182`): Fetches LLM-friendly markdown from URLs using Jina AI's reader service.

## Key Customizations

### Development Tools
- **Editor**: NeoVim (`nvim`) is the default editor, aliased to `vi`
- **Python**: Defaults to Python 3 (aliased `python` and `pip`)
- **Clojure**: Configured with Leiningen, clj-kondo, and custom REPL settings
- **Git**: GPG signing enabled by default, custom aliases for common workflows
- **Docker**: Convenience aliases for cleanup and AWS ECR login
- **Better CLI tools**: `bat` (instead of cat), `prettyping` (instead of ping), `ncdu` (instead of du)

### Git Configuration
- Commits are GPG-signed by default
- Default branch is `main`
- Custom aliases: `git l` (graph log), `git s` (short status), `git dm` (delete merged branches)
- Repository author: Paul Lam <paul@quantisan.com>

### Aider Configuration
- Model: GPT-5 with architect mode enabled
- Reasoning effort set to "high"
- Auto-accept architect changes disabled (manual review required)
- Prompt caching enabled
- Config file: `.aider.conf.yml`
- Environment file: `.env.aider`

### Environment Variables
- `EDITOR=nvim`
- `GOPATH=$HOME/Projects/gocode`
- AWS credentials sourced from AWS CLI config
- Clojure tools.deps config in `$HOME/.config`
- Node.js history size increased to 32768 entries

## Notable Aliases

**Navigation**:
- `p` → `cd ~/projects`
- `g` → `git`
- `lg` → `lazygit`

**Docker**:
- `dc` → `docker compose`
- `dockerclean` → Remove stopped containers and dangling images/volumes

**AWS/Infrastructure**:
- `t` → `terraform`
- `ecr` → Login to AWS ECR in us-west-2

**Utilities**:
- `update` → Update Homebrew and all packages
- `cleanup` → Recursively delete .DS_Store files
- `reload` → Reload shell configuration
