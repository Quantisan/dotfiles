# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Repository Overview

This is a personal macOS dotfiles repository, based on Mathias Bynens' dotfiles but customized for a development environment that includes Clojure, Python, AWS, Docker, and various AI/LLM tools.

## Installation and Setup Commands

### Install/Update Dotfiles
```bash
source bootstrap.sh
```
This syncs dotfiles to your home directory and creates a symlink for LLM templates. Only files git tracks are copied, so `git add` a new dotfile before bootstrapping; untracked and ignored files never reach `~`.

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

### Coding Agent Configuration

One rule decides where a file lives: **shared by all agents → `agents/`; used by one tool only → that tool's folder** (`.claude/`, `.codex/`, `.gemini/`). `bootstrap.sh` symlinks every tracked agent config file into `~` (other dotfiles are still rsync-copied), so edits are live; re-run `source bootstrap.sh` only when you add or remove a file or directory entry. Because the links point at this working tree, switching branches here changes the live config of every agent.

The `link` and `link_entries` calls in `bootstrap.sh` are the complete list of what is linked where; read them there rather than copying the list here.

- `agents/clojure.md` is linked to `~/.agents/clojure.md` because the global rules refer to that path.
- Codex and agy read `~/.agents/skills` natively; Claude Code does not, so shared skills are also linked into `~/.claude/skills`.
- Directories that other tools also write to are linked entry by entry, never as a whole: `~/.agents/` (skills installer lock file), `~/.claude/{skills,commands,workflows}` (Claude's `skills/synced`, reckon's `rk-*.md` commands), and `~/.codex/skills` (Codex's `.system`). Bootstrap removes dangling links that point into this repo (for example after a skill is renamed), and warns and skips if a real directory differing from the repo's already sits where a link belongs.
- `.claude/settings.json` is symlinked, so Claude's runtime permission changes appear as git modifications in this repo.
- `agy()` in `.functions` loads the tracked `personal.settings.json` with `--settings`; `~/.gemini/antigravity-cli/settings.json` stays untracked for machine-local state like `trustedWorkspaces`. `codex()` in `.functions` runs Codex with `--profile personal`, which reads the tracked `personal.config.toml`.
- The status lines for Claude and agy are Babashka scripts; they need `bb` from `brew.sh`.
- Runtime and session data (`~/.gemini/antigravity-cli/{brain,conversations,cache,log,...}`, `~/.gemini/config/projects/`, Gemini CLI's `~/.gemini/settings.json`) is intentionally not tracked.

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
