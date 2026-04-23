---
name: session-retrospective
description: Use when the user asks to analyze past sessions, do a session retrospective, or find evidence-based improvements for CLAUDE.md in this project
---

# Session Retrospective

## Overview

Analyzes session JSONL logs to find wrong-turn → recovery patterns and derive CLAUDE.md improvements.

## Stop — Data Source

**The data source is `~/.claude/projects/<project>/*.jsonl`.**

Do NOT read memory files, feedback files, git log, or CLAUDE.md as analysis inputs. Those are already-captured patterns. The point of this workflow is to find patterns that are NOT yet captured.

## Workflow

**Step 1 — Run the scanner**

```bash
python ~/.claude/skills/session-retrospective/analyze_sessions.py
```

Run from the project root — the script auto-detects the session directory from cwd.
Produces `docs/analysis/session-audit/manifest.md` and `docs/analysis/session-audit/extracts/*.md`.

**Step 2 — Read the manifest**

`docs/analysis/session-audit/manifest.md` lists sessions ranked by incident count with window ranges. Focus on the top rows.

**Step 3 — Read all extract files**

Each file under `extracts/` shows trimmed incident windows. Read them all — they're small by design.

## Signal Interpretation

| Tag | Meaning |
|---|---|
| `[C]` correction | User corrected the agent — a wrong turn was taken |
| `[R]` rework | Agent re-read or re-edited a file it already touched — context loss |
| `[F]` friction | Tool error, permission denial, or non-zero bash exit |
| `[Rv]` recovery | `git restore/reset` or `advisor()` after a long tool streak |

A clear wrong-turn arc: `[F]` or `[C]` at turn N, corrective tool calls, then session unblocks.

## Synthesis

After reading all extracts:

1. Cluster into 3–7 patterns — name each and cite evidence turns
2. Cross-check every pattern against existing `CLAUDE.md` and `memory/*.md` — skip anything already captured
3. Present as a table: `| Pattern | Evidence turns | Proposed CLAUDE.md text |`
4. Do not edit `CLAUDE.md` until the user approves each addition

## Common Mistakes

- **Reading memory/feedback files as the data source** — those are already-captured patterns, not new signal
- **Over-flagging rework on plan/doc files** — incremental edits to a single markdown document are normal; look for rework on *source code* files
- **Proposing additions that duplicate existing CLAUDE.md guidance** — always cross-check first
- **Applying CLAUDE.md edits without approval** — present as proposals only
