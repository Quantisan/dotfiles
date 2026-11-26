# Agent config layout — design

## Intent
Claude Code, Codex, Antigravity (agy) and pi are each wired into `~` a different way: some files copied, some linked; shared rules live under `.claude/`, shared skills under `.codex/`, and five workflows exist as diverged Claude-command and Codex-skill copies. Make one pattern so a change is made once and every agent sees it.

## Decisions (Paul)
- **Link, don't copy.** Every tracked file reaches `~` by symlink; edits are live.
- **Shared content in a neutral top-level `agents/`.**
- **DRY the duplicated workflows** into one shared skill each.

## Ground truth that shapes the layout
- Codex and agy natively read user skills from `~/.agents/skills` (found in both binaries; agy gives `~/.gemini` skills precedence). Claude Code does not — it only mentions that path in an import tool — so Claude needs its own links.
- Global rules have no shared location: `~/.claude/CLAUDE.md`, `~/.codex/AGENTS.md`, `~/.gemini/config/AGENTS.md`, `~/.pi/agent/AGENTS.md`.
- `~/.agents/`, `~/.claude/{skills,commands,workflows}` and `~/.codex/skills` also hold entries written by others (skills installer lock, Claude's `skills/synced`, reckon's `rk-*` commands, Codex's `.system`). Linking whole directories would capture or clobber those.

## Layout
```
agents/AGENTS.md        global rules         -> ~/.claude/CLAUDE.md, ~/.codex/AGENTS.md,
                                                ~/.gemini/config/AGENTS.md, ~/.pi/agent/AGENTS.md
agents/clojure.md       Clojure conventions  -> ~/.agents/clojure.md (rules reference this path)
agents/skills/<name>/   shared skills        -> ~/.agents/skills/<name>   (Codex, agy)
                                             -> ~/.claude/skills/<name>   (Claude)
.claude/ .codex/ .gemini/ .pi/               tool-only settings, skills, commands — linked into that tool's home
```
Rule: **shared → `agents/`; one tool only → that tool's folder.**

Directories that others also write to are linked **per entry**. Bootstrap prunes dangling links that point into the repo, and refuses (warns, skips) to replace a real directory it doesn't own.

## Shared skills
`commit`, `create-draft-pr`, `frame-minutes`, `rewrite-call-transcript`, `walk-branch-changes`. The Codex copy is the base (newer in all five); substantive Claude-only improvements are folded in. Wording is tool-neutral: no `$ARGUMENTS` or `!`-command injection. Claude-only frontmatter keys stay only if Codex and agy still load the skill. `agents/openai.yaml` metadata is kept (Codex UI; ignored by others). `gcm` alias uses `$commit`.

Tool-only: `atlassian-rovo-confluence` (Codex; needs its MCP), research/restate/discovery skills and session/spec-council commands (Claude).

## Bugs this fixes
- Codex had no global rules (broken relative `.codex/AGENTS.md` link; `AGENTS.md` excluded from sync).
- Bootstrap's `rsync --delete` wiped Claude's `~/.claude/skills/synced`.
- Stale `~/.codex/skills/meeting-minutes` (copy sync never pruned).
- Rules pointed Codex/agy at `~/.claude/clojure.md`.

## Approaches considered
- Copy everything (staged until bootstrap) — rejected: needs per-entry pruning anyway and invites drift.
- Keep shared content under a tool folder — rejected: tools keep reaching into each other's space.
- Link whole directories — rejected: captures or clobbers entries other tools write.

## Out of scope
Splitting Claude `settings.json` into tracked/local (Codex and agy already do); pi skills (pi not installed); converting Claude-only commands to skills.
